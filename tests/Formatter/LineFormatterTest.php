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
    expect('['.date('Y-m-d').'] log.WARNING: foo {} {}'."\n")->toBeSame($message);
  }

  public function testDefFormatWithArrayContext(): void {
    $formatter = new LineFormatter(LineFormatter::SIMPLE_FORMAT, 'Y-m-d');
    $message = $formatter->format(shape(
      'level' => LogLevel::ERROR,
      'level_name' => LogLevelName::ERROR,
      'channel' => 'meh',
      'message' => 'foo',
      'datetime' => new \DateTimeImmutable(),
      'extra' => dict[],
      'context' => dict[
        'foo' => 'bar',
        'baz' => 'qux',
        'bool' => false,
        'null' => null,
      ]
    ));
    expect(
      '['.date('Y-m-d').'] meh.ERROR: foo {"foo":"bar","baz":"qux","bool":false,"null":null} {}'."\n"
    )->toBeSame($message);
  }  
}
