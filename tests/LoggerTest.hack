use type Facebook\HackTest\HackTest;
use type HackLogging\Logger;
use type HackLogging\Handler\HandlerInterface;
use type HackLogging\Handler\NullHandler;
use type Usox\Log\{LogLevel, LogLevelName, LogLevelNameMap};
use namespace HH\Lib\{C, Vec};
use function Facebook\FBExpect\expect;

final class LoggerTest extends HackTest {

  public function testShouldReturnLoggerName(): void {
    $log = new Logger('hack-logging');
    expect($log->getName())
      ->toBeSame('hack-logging');
  }

  public function testShouldReturnLogLevelName(): void {
    expect(LogLevelNameMap::mapLevelToName(LogLevel::DEBUG))
      ->toBeSame(LogLevelName::DEBUG);
  }

  public function testAddHandlers(): void {
    $nullOne = new NullHandler();
    $nullTwo = new NullHandler();
    $log = new Logger('hack-logging', vec[
      $nullOne, $nullTwo
    ]);
    expect($log->popHandler())->toBeSame($nullOne);
    expect($log->popHandler())->toBeSame($nullTwo);
  }
}
