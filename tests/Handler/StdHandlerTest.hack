use type Facebook\HackTest\HackTest;
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\Handler\StdHandler;
use namespace HH\Lib\IO;
use function Facebook\FBExpect\expect;

final class StdHandlerTest extends HackTest {

  public async function testFunctionalStdHandleLogger(): Awaitable<void> {
    list($read, $write) = IO\pipe();
    $log = new Logger('hack-logging', vec[
      new StdHandler($write)
    ]);
    $result = \HH\Asio\join($log->writeAsync(LogLevel::DEBUG, 'hacklogging-test'));
    expect(await $read->readAsync())
      ->toContainSubstring('hack-logging.DEBUG: hacklogging-test {} {}');
  }
}
