use type Facebook\HackTest\HackTest;
use type HackLogging\Formatter\LineFormatter;
use type HackLogging\LogLevel;
use type HackLogging\LogLevelName;
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

  public function testDefFormatExtras(): void {
    $formatter = new LineFormatter(LineFormatter::SIMPLE_FORMAT, 'Y-m-d');
    $message = $formatter->format(shape(
      'level' => LogLevel::ERROR,
      'level_name' => LogLevelName::ERROR,
      'channel' => 'meh',
      'context' => dict[],
      'datetime' => new \DateTimeImmutable(),
      'extra' => dict['ip' => '127.0.0.1'],
      'message' => 'log',
    ));
    expect(
      '['.date('Y-m-d').'] meh.ERROR: log {} {"ip":"127.0.0.1"}'."\n"
    )->toBeSame($message);
  }

  public function testContextAndExtraReplacement(): void {
    $formatter = new LineFormatter('%context.foo% => %extra.foo%');
    $message = $formatter->format(shape(
      'level' => LogLevel::ERROR,
      'level_name' => LogLevelName::ERROR,
      'channel' => 'meh',
      'context' => dict['foo' => 'bar'],
      'datetime' => new \DateTimeImmutable(),
      'extra' => dict['foo' => 'xbar'],
      'message' => 'log',
    ));
    expect(
      'bar => xbar'
    )->toBeSame($message);
  }

  public function testDefFormatWithObject(): void {
    $formatter = new LineFormatter(LineFormatter::SIMPLE_FORMAT, 'Y-m-d');
    $message = $formatter->format(shape(
      'level' => LogLevel::ERROR,
      'level_name' => LogLevelName::ERROR,
      'channel' => 'meh',
      'context' => dict[],
      'datetime' => new \DateTimeImmutable(),
      'extra' => dict[
        'foo' => new TestFoo(),
        'bar' => new TestBar(),
        'baz' => vec[],
        'res' => fopen('php://memory', 'rb')
      ],
      'message' => 'foobar',
    ));
    expect(
      '['.date('Y-m-d').'] meh.ERROR: foobar {} {"foo":{"foo":"fooValue"},"bar":{},"baz":[],"res":[]}'."\n"
    )->toBeSame($message);
  }
}

class TestFoo {
  public string $foo = 'fooValue';
}

class TestBar {
  public function __toString(): string {
    return 'bar';
  }
}
