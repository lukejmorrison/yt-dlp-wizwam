"""
Setup script for yt-dlp-wizwam package.

This package provides both CLI and web interfaces for downloading videos
from 1800+ websites using yt-dlp.
"""

from setuptools import setup, find_packages
import os
import re

# Read README for long description
def read_file(filename):
    """Read file contents."""
    filepath = os.path.join(os.path.dirname(__file__), filename)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    return ''

def get_version():
    """Extract version from yt_dlp_wizwam/__init__.py."""
    init_path = os.path.join('yt_dlp_wizwam', '__init__.py')
    with open(init_path, 'r', encoding='utf-8') as f:
        content = f.read()
        match = re.search(r"^__version__\s*=\s*['\"]([^'\"]*)['\"]", content, re.M)
        if match:
            return match.group(1)
    raise RuntimeError('Unable to find version string in yt_dlp_wizwam/__init__.py')

setup(
    name='yt-dlp-wizwam',
    version=get_version(),
    author='Luke J Morrison',
    author_email='your.email@example.com',  # TODO: Update with real email
    description='Advanced YouTube downloader with CLI and web interface',
    long_description=read_file('README.md'),
    long_description_content_type='text/markdown',
    url='https://github.com/lukejmorrison/yt-dlp-wizwam',
    project_urls={
        'Bug Reports': 'https://github.com/lukejmorrison/yt-dlp-wizwam/issues',
        'Source': 'https://github.com/lukejmorrison/yt-dlp-wizwam',
        'Documentation': 'https://github.com/lukejmorrison/yt-dlp-wizwam/wiki',
    },
    packages=find_packages(exclude=['tests', 'tests.*']),
    
    # Include package data (templates, static files)
    include_package_data=True,
    package_data={
        'yt_dlp_wizwam': [
            'templates/*.html',
            'static/**/*',
            'static/css/*',
            'static/js/*',
            'static/dist/*',
            'static/src/*',
        ],
    },
    
    # Python version requirement
    python_requires='>=3.10',
    
    # Core dependencies
    install_requires=[
        'yt-dlp>=2024.10.07',      # Video downloader engine
        'Flask>=3.0.0',             # Web framework
        'Flask-SocketIO>=5.3.0',    # Real-time updates
        'Flask-CORS>=4.0.0',        # Cross-origin support
        'click>=8.1.0',             # CLI framework
        'requests>=2.31.0',         # HTTP library
        'eventlet>=0.40.0',         # Async I/O for SocketIO
        'python-socketio>=5.10.0',  # SocketIO client
        'imageio-ffmpeg>=0.4.9',    # Bundled FFmpeg
        'psutil>=5.9.0',            # System monitoring
    ],
    
    # Optional dependencies
    extras_require={
        'dev': [
            'pytest>=7.4.0',
            'pytest-cov>=4.1.0',
            'black>=23.7.0',
            'flake8>=6.1.0',
            'mypy>=1.5.0',
            'twine>=4.0.0',  # For uploading to PyPI
        ],
        'docker': [
            # For Docker-based deployment (optional)
            'redis>=5.0.0',
            'celery>=5.3.0',
        ],
    },
    
    # Command-line entry points
    entry_points={
        'console_scripts': [
            'downloader=yt_dlp_wizwam.cli:main',           # Main CLI
            'yt-dlp-web=yt_dlp_wizwam.cli:start_web',      # Web server alias
            'yt-dlp-cli=yt_dlp_wizwam.cli:cli_download',   # CLI download alias
        ],
    },
    
    # Classifiers for PyPI
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: End Users/Desktop',
        'Topic :: Multimedia :: Video',
        'Topic :: Internet :: WWW/HTTP :: Dynamic Content',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Programming Language :: Python :: 3.12',
        'Operating System :: OS Independent',
        'Environment :: Console',
        'Environment :: Web Environment',
    ],
    
    keywords='youtube download video yt-dlp downloader cli web',
    
    # License
    license='MIT',
    
    # Zip safe
    zip_safe=False,
)
