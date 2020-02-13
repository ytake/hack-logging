# hack-logging

[![Build Status](https://travis-ci.org/ytake/hack-logging.svg?branch=master)](https://travis-ci.org/ytake/hack-logging)

## Requirements

HHVM 4.35.0 and above.

## Usage

```bash
$ composer require hack-logging/hack-logging
```

### StdHandler

```hack
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\Handler\StdHandler;
use namespace HH\Lib\Experimental\IO;

list($read, $write) = IO\pipe_non_disposable();
$log = new Logger('hack-logging', vec[
  new StdHandler($write)
]);
\HH\Asio\join(
  $log->writeAsync(LogLevel::DEBUG, 'hacklogging-test')
);
```

### FilesystemHandler

```hack
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\Handler\FilesystemHandler;
use namespace HH\Lib\Experimental\Filesystem;

$filename = sys_get_temp_dir().'/'.bin2hex(random_bytes(16));
$file = Filesystem\open_write_only_non_disposable($filename);
$log = new Logger('hack-logging', vec[
  new FilesystemHandler($file)
]);
\HH\Asio\join(
  $log->writeAsync(LogLevel::DEBUG, 'hacklogging-test', dict['context' => vec['nice']])
);
```
