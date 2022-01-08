# hack-logging

[![Build Status](https://travis-ci.org/ytake/hack-logging.svg?branch=master)](https://travis-ci.org/ytake/hack-logging)

## Requirements

HHVM 4.95 and above.

## Usage

```bash
$ composer require hack-logging/hack-logging
```

### StdHandler

```hack
use namespace HackLogging;
use namespace HH\Lib\IO;

async function fvAsync(): Awaitable<void> {
  list($read, $write) = IO\pipe();

  $log = new HackLogging\Logger('hack-logging', vec[
    new HackLogging\Handler\StdHandler($write),
  ]);

  await $log->writeAsync(
    HackLogging\LogLevel::DEBUG,
    'hacklogging-test',
  );
}
```

### FilesystemHandler

```hack
use namespace HackLogging;
use namespace HH\Lib\File;
use function bin2hey();
use function random_bytes;
use function sys_get_temp_dir;

async function fvAsync(): Awaitable<void> {
  $filename = sys_get_temp_dir() . '/' . bin2hex(random_bytes(16));
  $file = File\open_write_only($filename);
  $log = new HackLogging\Logger('hack-logging', vec[
    new HackLogging\Handler\FilesystemHandler($file),
  ]);
  await $log->writeAsync(
    HackLogging\LogLevel::DEBUG,
    'hacklogging-test',
    dict[
      'context' => vec['nice'],
    ],
  );
}
```
