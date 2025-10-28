from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="yt-dlp-wizwam",
    version="0.1.0",
    author="Luke Morrison",
    description="A local yt-dlp web and CLI interface with extensible design",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/lukejmorrison/yt-dlp-wizwam",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
    install_requires=[
        "yt-dlp>=2024.10.0",
        "flask>=3.0.0",
        "flask-cors>=4.0.0",
        "click>=8.1.0",
        "pyyaml>=6.0.0",
    ],
    entry_points={
        "console_scripts": [
            "wizwam=wizwam.cli:main",
        ],
    },
)
