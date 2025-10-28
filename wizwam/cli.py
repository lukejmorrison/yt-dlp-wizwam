"""
CLI interface for yt-dlp-wizwam
"""
import click
import json
from pathlib import Path
from typing import Optional

from wizwam.core.downloader import Downloader
from wizwam.core.manager import plugin_manager
from wizwam.plugins.ytdlp_plugin import YtDlpPlugin


@click.group()
@click.version_option(version='0.1.0')
def cli():
    """
    yt-dlp-wizwam: A local yt-dlp web and CLI interface with extensible design
    """
    pass


@cli.command()
@click.argument('url')
@click.option('-o', '--output', default='./downloads', help='Output directory')
@click.option('-f', '--format', default='best', help='Format to download (best, worst, mp4, etc.)')
@click.option('--audio-only', is_flag=True, help='Download audio only')
@click.option('--info-only', is_flag=True, help='Get info without downloading')
def download(url: str, output: str, format: str, audio_only: bool, info_only: bool):
    """
    Download video/audio from URL
    """
    downloader = Downloader(output)
    
    if info_only:
        click.echo(f"Getting info for: {url}")
        result = downloader.get_info(url)
        click.echo(json.dumps(result, indent=2))
        return
    
    options = {'format': format}
    if audio_only:
        options['format'] = 'bestaudio/best'
        options['postprocessors'] = [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'mp3',
        }]
    
    click.echo(f"Downloading from: {url}")
    result = downloader.download(url, options)
    
    if result.get('success'):
        click.echo(f"✓ Success! Downloaded: {result.get('title')}")
        click.echo(f"  File: {result.get('filename')}")
    else:
        click.echo(f"✗ Error: {result.get('error')}", err=True)
        exit(1)


@cli.command()
def plugins():
    """
    List available plugins
    """
    # Register default plugin
    plugin_manager.register_plugin(YtDlpPlugin)
    
    # Discover additional plugins
    plugin_dir = Path(__file__).parent / 'plugins'
    plugin_manager.discover_plugins(plugin_dir)
    
    plugin_list = plugin_manager.list_plugins()
    
    if not plugin_list:
        click.echo("No plugins registered")
        return
    
    click.echo("Available plugins:")
    for plugin in plugin_list:
        click.echo(f"\n  {plugin['name']} (v{plugin['version']})")
        click.echo(f"    Type: {plugin['type']}")
        click.echo(f"    Description: {plugin['description']}")


@cli.command()
@click.option('-p', '--port', default=5000, help='Port to run the web server on')
@click.option('-h', '--host', default='127.0.0.1', help='Host to bind to')
@click.option('--debug', is_flag=True, help='Run in debug mode')
def web(port: int, host: str, debug: bool):
    """
    Start the web interface
    """
    from wizwam.web.app import create_app
    
    app = create_app()
    click.echo(f"Starting web server on http://{host}:{port}")
    app.run(host=host, port=port, debug=debug)


def main():
    """Entry point for CLI"""
    cli()


if __name__ == '__main__':
    main()
