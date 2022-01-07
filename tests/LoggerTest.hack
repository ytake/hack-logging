use namespace HackLogging;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class LoggerTest extends HackTest {
  public function testShouldReturnLoggerName(): void {
    $log = new HackLogging\Logger('hack-logging');
    expect($log->getName())
      ->toBeSame('hack-logging');
  }

  public function testShouldReturnLogLevelName(): void {
    expect(HackLogging\Logger::getLevelName(HackLogging\LogLevel::DEBUG))
      ->toBeSame(HackLogging\LogLevelName::DEBUG);
  }

  public async function testFunctionalNullHandleLoggerAsync(): Awaitable<void> {
    $log = new HackLogging\Logger('hack-logging', vec[
      new HackLogging\Handler\NullHandler(),
    ]);
    $result = await $log->writeAsync(HackLogging\LogLevel::DEBUG, 'hacklogging-test');
    expect($result)->toBeTrue();
  }

  public function testAddHandlers(): void {
    $nullOne = new HackLogging\Handler\NullHandler();
    $nullTwo = new HackLogging\Handler\NullHandler();
    $log = new HackLogging\Logger('hack-logging', vec[
      $nullOne,
      $nullTwo,
    ]);
    expect($log->popHandler())->toBeSame($nullOne);
    expect($log->popHandler())->toBeSame($nullTwo);
  }
}
