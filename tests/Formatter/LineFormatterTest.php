<?hh // strict

use type Facebook\HackTest\HackTest;
use type HackLogging\Formatter\LineFormatter;
use type HackLogging\Logger;
use type HackLogging\LogLevel;
use type HackLogging\LogLevelName;
use namespace HH\Lib\{C, Vec};
use function Facebook\FBExpect\expect;

final class LineFormatterTest extends HackTest {

  public function testDefFormatWithString(): void {
    $formatter = new LineFormatter(LineFormatter::SIMPLE_FORMAT, 'Y-m-d');
    $message = $formatter->format(shape(
      'level' => LogLevel::WARNING,
      'level_name' => LogLevelName::WARNING,
      'channel' => 'log',
      'context' => dict[],
      'message' => 'foo',
      'datetime' => new \DateTimeImmutable(),
      'extra' => dict[],
    ));
    expect($message)->toBeSame(
      '['.date('Y-m-d').'] log.WARNING: foo {} {}'."\n"
    );
  }
}
