# hack-logging

[![Build Status](https://travis-ci.org/ytake/hack-logging.svg?branch=master)](https://travis-ci.org/ytake/hack-logging)

## Requirements

HHVM 4.41.0 and above.

## Usage

```bash
$ composer require hack-logging/hack-logging
```

### StdHandler

```hack
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\Handler\StdHandler;
use namespace HH\Lib\IO;

list($read, $write) = IO\pipe();
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
use namespace HH\Lib\File;

$filename = sys_get_temp_dir().'/'.bin2hex(random_bytes(16));
$file = File\open_write_only($filename);
$log = new Logger('hack-logging', vec[
  new FilesystemHandler($file)
]);
\HH\Asio\join(
  $log->writeAsync(LogLevel::DEBUG, 'hacklogging-test', dict['context' => vec['nice']])
);
```
