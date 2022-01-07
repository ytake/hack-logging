use namespace HackLogging;
use namespace HH\Lib\IO;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class StdHandlerTest extends HackTest {
  public async function testFunctionalStdHandleLogger(): Awaitable<void> {
    list($read, $write) = IO\pipe();
    $log = new HackLogging\Logger('hack-logging', vec[
      new HackLogging\Handler\StdHandler($write),
    ]);

    await $log->writeAsync(
      HackLogging\LogLevel::DEBUG,
      'hacklogging-test',
    );

    expect(await $read->readAllAsync())
      ->toContainSubstring('hack-logging.DEBUG: hacklogging-test {} {}');
  }
}
