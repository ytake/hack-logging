<?hh // strict

use type Facebook\HackTest\HackTest;
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\LogLevelName;
use type HackLogging\Handler\NullHandler;
use namespace HH\Lib\{C, Vec};
use function Facebook\FBExpect\expect;

final class LoggerTest extends HackTest {

  public function testShouldReturnLoggerName(): void {
    $log = new Logger('hack-logging');
    expect($log->getName())
      ->toBeSame('hack-logging');
  }

  public function testShouldReturnLogLevelName(): void {
    expect(Logger::getLevelName(LogLevel::DEBUG))
      ->toBeSame(LogLevelName::DEBUG);
  }

  public function testFunctionalNullHandleLogger(): void {
    $log = new Logger('hack-logging', vec[
      new NullHandler()
    ]);
    $result = \HH\Asio\join($log->writeAsync(LogLevel::DEBUG, 'hacklogging-test'));
    expect($result)->toBeTrue();
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
