# logrotate

log rotate tool written in Swift base on Swift NIO

## Installation

```
git clone https://github.com/DanboDuan/logrotate
cd logrotate
bash build.sh
cp .build/apple/Products/Release/logrotate path-to-bin
```

## Usage

```
logrotate --help

OVERVIEW: log rotate tool for macOS base on NIO

USAGE: logrotate [--suffix <suffix>] [--MB <MB>] [--KB <KB>] [--B <B>] [--line <line>] [--max <max>] [--output <output>] [--verbose]

OPTIONS:
  --suffix <suffix>       Log file suffix (default: .log)
  -M, --MB <MB>           MB size for every log file
  -K, --KB <KB>           KB size for every log file
  -B, --B <B>             Byte size for every log file
  -L, --line <line>       Line count for every log file 
  --max <max>             Max count of log files to keep
  --output <output>       Output directory
  --verbose               Verbose print log to stdout 
  --version               Show the version.
  -h, --help              Show help information.

## logrotate log files to /tmp/log/ with size limit to 10 MB or line count 1000, and only keep max 10 files
my_program | logrotate --line 1000 --MB 10 --max 10 --output /tmp/log/ --verbose

```
## License

[MIT](https://github.com/DanboDuan/logrotate/blob/master/LICENSE)
