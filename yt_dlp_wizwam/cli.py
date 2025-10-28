"""
Command-line interface for yt-dlp-wizwam.

Provides CLI commands for downloading videos and starting the web interface.
Uses Click framework for argument parsing and command structure.
"""

import click
import sys
import webbrowser
import time
import threading
from pathlib import Path

from yt_dlp_wizwam.config import Config
from yt_dlp_wizwam import __version__


@click.group(invoke_without_command=True)
@click.option('--version', is_flag=True, help='Show version and exit')
@click.pass_context
def main(ctx, version):
    """
    yt-dlp-wizwam: Advanced YouTube downloader with CLI and web interface.
    
    Run without arguments to start the web interface.
    Use 'downloader download' for CLI downloads.
    
    Examples:
        downloader                    # Start web interface
        downloader download {URL}     # Download video via CLI
        downloader web --port 8080    # Web interface on custom port
    """
    if version:
        click.echo(f'yt-dlp-wizwam version {__version__}')
        ctx.exit()
    
    # If no subcommand provided, default to web interface
    if ctx.invoked_subcommand is None:
        ctx.invoke(web)


@main.command()
@click.argument('url')
@click.option('--quality', default='720p', 
              type=click.Choice(['4k', '1080p', '720p', '480p', '360p']),
              help='Video quality (default: 720p)')
@click.option('--video-codec', default='avc1',
              type=click.Choice(['avc1', 'av1', 'vp9']),
              help='Video codec (default: avc1/H.264)')
@click.option('--audio-codec', default='m4a',
              type=click.Choice(['m4a', 'opus', 'mp3']),
              help='Audio codec (default: m4a/AAC)')
@click.option('--audio-only', is_flag=True,
              help='Download audio only')
@click.option('--output-dir', type=click.Path(),
              help=f'Output directory (default: {Config.DOWNLOAD_DIR})')
@click.option('--verbose', '-v', is_flag=True,
              help='Verbose output')
def download(url, quality, video_codec, audio_codec, audio_only, output_dir, verbose):
    """
    Download a video via CLI.
    
    Examples:
        downloader download https://youtube.com/watch?v=...
        downloader download {URL} --quality 1080p --video-codec av1
        downloader download {URL} --audio-only --audio-codec opus
    """
    from yt_dlp_wizwam.downloader import download_video
    
    # Set up configuration
    if output_dir:
        Config.DOWNLOAD_DIR = output_dir
    Config.ensure_directories()
    
    # Configure verbosity
    if verbose:
        Config.LOG_LEVEL = 'DEBUG'
    
    click.echo(f'📥 Downloading from: {url}')
    click.echo(f'📁 Output directory: {Config.DOWNLOAD_DIR}')
    
    if audio_only:
        click.echo(f'🎵 Audio-only mode, codec: {audio_codec}')
    else:
        click.echo(f'🎬 Quality: {quality}, Video: {video_codec}, Audio: {audio_codec}')
    
    try:
        # Perform download
        result = download_video(
            url=url,
            quality=quality,
            video_codec=video_codec,
            audio_codec=audio_codec,
            audio_only=audio_only,
            verbose=verbose
        )
        
        if result['status'] == 'success':
            click.echo(f'\n✅ Download complete!')
            click.echo(f'📄 File: {result["filename"]}')
            click.echo(f'💾 Size: {result.get("filesize", "Unknown")}')
        else:
            click.echo(f'\n❌ Download failed: {result.get("error", "Unknown error")}')
            sys.exit(1)
            
    except KeyboardInterrupt:
        click.echo('\n\n⚠️  Download cancelled by user')
        sys.exit(130)
    except Exception as e:
        click.echo(f'\n❌ Error: {e}', err=True)
        if verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)


@main.command()
@click.option('--host', default=Config.HOST,
              help=f'Host to bind to (default: {Config.HOST})')
@click.option('--port', default=None, type=int,
              help=f'Port to listen on (default: {Config.PORT}, auto-detects if in use)')
@click.option('--debug', is_flag=True,
              help='Enable debug mode')
@click.option('--open-browser', is_flag=True,
              help='Automatically open browser')
def web(host, port, debug, open_browser):
    """
    Start the web interface.
    
    Examples:
        downloader web                        # Default (localhost:8080, auto-detect if in use)
        downloader web --port 5000            # Force specific port
        downloader web --host 0.0.0.0         # Listen on all interfaces
        downloader web --open-browser         # Auto-open browser
    """
    from yt_dlp_wizwam.web import create_app, socketio, is_port_in_use, find_available_port
    
    # Update configuration
    Config.HOST = host
    Config.DEBUG = debug
    Config.ensure_directories()
    Config.validate()
    
    # Auto-detect available port if not specified
    if port is None:
        port = Config.PORT
        if is_port_in_use(port, host):
            click.echo(f'⚠️  Port {port} is already in use, finding alternative...')
            alternative_port = find_available_port(start_port=port, max_attempts=20, host=host)
            if alternative_port:
                port = alternative_port
                click.echo(f'✅ Using port {port} instead')
            else:
                click.echo(f'❌ Error: Could not find an available port (tried {port}-{port+19})', err=True)
                click.echo('💡 Try stopping other services or specify a port manually with --port', err=True)
                sys.exit(1)
    else:
        # User specified a port, check if it's available
        if is_port_in_use(port, host):
            click.echo(f'❌ Error: Port {port} is already in use', err=True)
            click.echo('💡 Try a different port with --port or let the app auto-detect', err=True)
            sys.exit(1)
    
    Config.PORT = port
    
    click.echo('🚀 Starting yt-dlp-wizwam web interface...')
    click.echo(f'🌐 Server: http://{host}:{port}')
    click.echo(f'📁 Downloads: {Config.DOWNLOAD_DIR}')
    click.echo(f'📊 Mode: {"Development" if debug else "Production"}')
    click.echo('\n💡 Press Ctrl+C to stop\n')
    
    # Open browser in background thread after server starts
    if open_browser:
        url = f'http://{"localhost" if host == "0.0.0.0" else host}:{port}'
        
        def open_browser_delayed():
            """Open browser after giving server time to start."""
            # Wait for server to be ready
            time.sleep(1.5)
            
            click.echo(f'🔗 Opening {url} in browser...')
            try:
                # Suppress stderr to hide Wayland warnings
                import os
                import subprocess
                devnull = open(os.devnull, 'w')
                old_stderr = os.dup(2)
                os.dup2(devnull.fileno(), 2)
                
                webbrowser.open(url)
                
                # Restore stderr
                os.dup2(old_stderr, 2)
                devnull.close()
            except Exception:
                # Fallback to normal webbrowser.open if the above fails
                webbrowser.open(url)
        
        # Start browser opener in background thread
        browser_thread = threading.Thread(target=open_browser_delayed, daemon=True)
        browser_thread.start()
    
    # Create and run Flask app
    app = create_app()
    
    try:
        socketio.run(
            app,
            host=host,
            port=port,
            debug=debug,
            use_reloader=debug,
            log_output=debug
        )
    except KeyboardInterrupt:
        click.echo('\n\n⚠️  Server stopped by user')
    except Exception as e:
        click.echo(f'\n❌ Server error: {e}', err=True)
        sys.exit(1)


# Convenience aliases for entry points
def start_web():
    """Entry point for 'yt-dlp-web' command."""
    # Simulate 'downloader web' command
    sys.argv = [sys.argv[0], 'web'] + sys.argv[1:]
    main()


def cli_download():
    """Entry point for 'yt-dlp-cli' command."""
    # Simulate 'downloader download' command
    if len(sys.argv) < 2:
        click.echo('Usage: yt-dlp-cli {URL} [OPTIONS]')
        click.echo('Try: yt-dlp-cli --help')
        sys.exit(1)
    
    sys.argv = [sys.argv[0], 'download'] + sys.argv[1:]
    main()


if __name__ == '__main__':
    main()
