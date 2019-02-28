use type Facebook\HackTest\HackTest;
use type HackLogging\Logger;
use type HackLogging\LogLevelName;
use type HackLogging\Handler\StdHandler;
use type Usox\Log\LogLevel;
use namespace HH\Lib\{C, Vec};
use namespace HH\Lib\Experimental\IO;
use function Facebook\FBExpect\expect;

final class StdHandlerTest extends HackTest {

  public function testFunctionalNullHandleLogger(): void {
    list($read, $write) = IO\pipe_non_disposable();
    $log = new Logger('hack-logging', vec[
      new StdHandler($write)
    ]);
    $log->log(LogLevel::DEBUG, 'hacklogging-test');
    expect($read->rawReadBlocking())
      ->toContain('hack-logging.DEBUG: hacklogging-test {} {}');
  }
}
