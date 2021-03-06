use type Facebook\HackTest\HackTest;
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\Handler\FilesystemHandler;
use type HackLogging\Handler\StdHandler;
use namespace HH\Lib\{File, IO};
use function Facebook\FBExpect\expect;

final class FilesystemHandlerTest extends HackTest {

  public async function testFunctionalFilesystemHandleLogger(): Awaitable<void> {
    $filename = sys_get_temp_dir().'/'.bin2hex(random_bytes(16));
    $file = File\open_write_only($filename);
    $log = new Logger('hack-logging', vec[
      new FilesystemHandler($file)
    ]);
    \HH\Asio\join($log->writeAsync(LogLevel::DEBUG, 'hacklogging-test', dict['context' => vec['nice']]));
    expect(file_get_contents($filename))
      ->toContain('hack-logging.DEBUG: hacklogging-test {"context":["nice"]} {}');
    unlink($filename);
  }


  public async function testFunctionalComplexStdHandleLogger(): Awaitable<void> {
    list($read, $write) = IO\pipe();
    $filename = sys_get_temp_dir().'/'.bin2hex(random_bytes(16));
    $file = File\open_write_only($filename);
    $log = new Logger('hack-logging', vec[
      new StdHandler($write),
      new FilesystemHandler($file)
    ]);
    \HH\Asio\join($log->writeAsync(LogLevel::DEBUG, 'hacklogging-test', dict['context' => vec['nice']]));
    expect(await $read->readAsync())
      ->toContainSubstring('hack-logging.DEBUG: hacklogging-test {"context":["nice"]} {}');
    expect(file_get_contents($filename))
      ->toContainSubstring('hack-logging.DEBUG: hacklogging-test {"context":["nice"]} {}');
    unlink($filename);
  }
}
