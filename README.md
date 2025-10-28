# yt-dlp-wizwam

A local yt-dlp web and CLI interface with an open, extensible design for downloading videos and audio from various platforms.

## Features

- 🎬 **Web Interface**: Beautiful, modern web UI for downloading videos
- 💻 **CLI Interface**: Powerful command-line interface for automation
- 🔌 **Plugin Architecture**: Extensible design for custom downloaders and processors
- 🚀 **Easy to Use**: Simple installation and intuitive interfaces
- 🛠️ **Configurable**: YAML-based configuration system
- 🔒 **Local**: Runs entirely on your machine, no external services

## Installation

### Prerequisites

- Python 3.8 or higher
- pip

### Install from source

```bash
git clone https://github.com/lukejmorrison/yt-dlp-wizwam.git
cd yt-dlp-wizwam
pip install -e .
```

### Install dependencies only

```bash
pip install -r requirements.txt
```

## Usage

### Web Interface

Start the web server:

```bash
wizwam web
```

Or with custom options:

```bash
wizwam web --port 8080 --host 0.0.0.0 --debug
```

Then open your browser to `http://localhost:5000` (or your custom port).

### CLI Interface

Download a video:

```bash
wizwam download https://www.youtube.com/watch?v=example
```

Download with custom format:

```bash
wizwam download https://www.youtube.com/watch?v=example --format best
```

Download audio only:

```bash
wizwam download https://www.youtube.com/watch?v=example --audio-only
```

Get video info without downloading:

```bash
wizwam download https://www.youtube.com/watch?v=example --info-only
```

Custom output directory:

```bash
wizwam download https://www.youtube.com/watch?v=example --output ./my-videos
```

List available plugins:

```bash
wizwam plugins
```

## Extensibility

### Plugin Architecture

yt-dlp-wizwam uses a plugin-based architecture that allows you to extend functionality easily.

#### Creating a Custom Downloader Plugin

```python
# wizwam/plugins/my_plugin.py
from typing import Dict, Any, Optional
from wizwam.core.plugin import DownloaderPlugin

class MyCustomPlugin(DownloaderPlugin):
    @property
    def name(self) -> str:
        return "my-custom-downloader"
    
    @property
    def version(self) -> str:
        return "1.0.0"
    
    @property
    def description(self) -> str:
        return "My custom downloader"
    
    def download(self, url: str, options: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        # Your custom download logic
        return {
            'success': True,
            'title': 'Downloaded',
            'url': url
        }
```

#### Creating a Processor Plugin

```python
# wizwam/plugins/my_processor.py
from typing import Dict, Any
from wizwam.core.plugin import ProcessorPlugin

class MyProcessor(ProcessorPlugin):
    @property
    def name(self) -> str:
        return "my-processor"
    
    def process(self, data: Dict[str, Any]) -> Dict[str, Any]:
        # Your custom processing logic
        return data
```

Plugins are automatically discovered from the `wizwam/plugins` directory.

### API Endpoints

The web interface exposes a REST API:

- `GET /` - Web interface
- `GET /api/health` - Health check
- `POST /api/info` - Get video information
  ```json
  {"url": "https://www.youtube.com/watch?v=example"}
  ```
- `POST /api/download` - Download video
  ```json
  {
    "url": "https://www.youtube.com/watch?v=example",
    "options": {"format": "best"}
  }
  ```
- `GET /api/plugins` - List available plugins

## Configuration

Edit `config.yaml` to customize settings:

```yaml
output_dir: ./downloads
format: best

server:
  host: 127.0.0.1
  port: 5000
  debug: false

plugins:
  auto_discover: true
  plugin_dir: wizwam/plugins
```

You can also create a `config.local.yaml` file for local overrides (this file is gitignored).

## Development

### Project Structure

```
yt-dlp-wizwam/
├── wizwam/
│   ├── __init__.py
│   ├── cli.py              # CLI interface
│   ├── core/
│   │   ├── __init__.py
│   │   ├── downloader.py   # Core download functionality
│   │   ├── plugin.py       # Plugin base classes
│   │   └── manager.py      # Plugin manager
│   ├── plugins/
│   │   ├── __init__.py
│   │   └── ytdlp_plugin.py # Default yt-dlp plugin
│   └── web/
│       ├── __init__.py
│       ├── app.py          # Flask application
│       └── templates/
│           └── index.html  # Web UI
├── config.yaml             # Configuration
├── requirements.txt        # Dependencies
├── setup.py               # Package setup
└── README.md              # Documentation
```

### Running Tests

```bash
# Install dev dependencies
pip install pytest pytest-cov

# Run tests
pytest

# Run with coverage
pytest --cov=wizwam
```

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Built on top of the excellent [yt-dlp](https://github.com/yt-dlp/yt-dlp) project
- Web interface powered by Flask