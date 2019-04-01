use type Facebook\HackTest\HackTest;
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\Handler\StdHandler;
use namespace HH\Lib\Experimental\IO;
use function Facebook\FBExpect\expect;

final class StdHandlerTest extends HackTest {

  public function testFunctionalStdHandleLogger(): void {
    list($read, $write) = IO\pipe_non_disposable();
    $log = new Logger('hack-logging', vec[
      new StdHandler($write)
    ]);
    $result = \HH\Asio\join($log->writeAsync(LogLevel::DEBUG, 'hacklogging-test'));
    expect($read->rawReadBlocking())
      ->toContain('hack-logging.DEBUG: hacklogging-test {} {}');
  }
}
