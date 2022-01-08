use namespace HackLogging;
use namespace HH\Lib\{File, IO};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class FilesystemHandlerTest extends HackTest {
  public async function testFunctionalFilesystemHandleLoggerAsync(): Awaitable<void> {
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

    $file->close();

    $readLog = File\open_read_only($filename);
    $content = await $readLog->readAllAsync();
    $readLog->close();

    expect($content)
      ->toContainSubstring('hack-logging.DEBUG: hacklogging-test {"context":["nice"]} {}');
    unlink($filename);
  }

  public async function testFunctionalComplexStdHandleLoggerAsync(): Awaitable<void> {
    list($read, $write) = IO\pipe();
    $filename = sys_get_temp_dir() . '/' . bin2hex(random_bytes(16));
    $file = File\open_write_only($filename);
    $log = new HackLogging\Logger('hack-logging', vec[
      new HackLogging\Handler\StdHandler($write),
      new HackLogging\Handler\FilesystemHandler($file),
    ]);

    await $log->writeAsync(
      HackLogging\LogLevel::DEBUG,
      'hacklogging-test',
      dict[
        'context' => vec['nice'],
      ],
    );

    expect(await $read->readAllowPartialSuccessAsync())
      ->toContainSubstring('hack-logging.DEBUG: hacklogging-test {"context":["nice"]} {}');

    $readLog = File\open_read_only($filename);
    $content = await $readLog->readAllAsync();
    $readLog->close();

    expect($content)
      ->toContainSubstring('hack-logging.DEBUG: hacklogging-test {"context":["nice"]} {}');

    unlink($filename);
  }
}
