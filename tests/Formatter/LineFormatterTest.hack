use namespace HH\Lib\{
  IO,
  Str,
};
use namespace HackLogging;
use type DateTimeImmutable;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class LineFormatterTest extends HackTest {
  public function testDefFormatWithString(): void {
    $formatter = new HackLogging\Formatter\LineFormatter(
      HackLogging\Formatter\LineFormatter::SIMPLE_FORMAT,
      'Y-m-d',
    );

    $message = $formatter->format(shape(
      'level' => HackLogging\LogLevel::WARNING,
      'level_name' => HackLogging\LogLevelName::WARNING,
      'channel' => 'log',
      'context' => dict[],
      'message' => 'foo',
      'datetime' => new DateTimeImmutable(),
      'extra' => dict[],
    ));

    expect(Str\format(
      '[%s] log.WARNING: foo {} {}%s',
      (new DateTimeImmutable())->format('Y-m-d'),
      "\n",
    ))->toBeSame($message);
  }

  public function testDefFormatWithArrayContext(): void {
    $formatter = new HackLogging\Formatter\LineFormatter(
      HackLogging\Formatter\LineFormatter::SIMPLE_FORMAT,
      'Y-m-d',
    );

    $message = $formatter->format(shape(
      'level' => HackLogging\LogLevel::ERROR,
      'level_name' => HackLogging\LogLevelName::ERROR,
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

    expect(Str\format(
      '[%s] meh.ERROR: foo {"foo":"bar","baz":"qux","bool":false,"null":null} {}%s',
      (new DateTimeImmutable())->format('Y-m-d'),
      "\n",
    ))->toBeSame($message);
  }

  public function testDefFormatExtras(): void {
    $formatter = new HackLogging\Formatter\LineFormatter(
      HackLogging\Formatter\LineFormatter::SIMPLE_FORMAT,
      'Y-m-d',
    );

    $message = $formatter->format(shape(
      'level' => HackLogging\LogLevel::ERROR,
      'level_name' => HackLogging\LogLevelName::ERROR,
      'channel' => 'meh',
      'context' => dict[],
      'datetime' => new DateTimeImmutable(),
      'extra' => dict['ip' => '127.0.0.1'],
      'message' => 'log',
    ));

    expect(Str\format(
      '[%s] meh.ERROR: log {} {"ip":"127.0.0.1"}%s',
      (new DateTimeImmutable())->format('Y-m-d'),
      "\n",
    ))->toBeSame($message);
  }

  public function testContextAndExtraReplacement(): void {
    $formatter = new HackLogging\Formatter\LineFormatter('%context.foo% => %extra.foo%');
    $message = $formatter->format(shape(
      'level' => HackLogging\LogLevel::ERROR,
      'level_name' => HackLogging\LogLevelName::ERROR,
      'channel' => 'meh',
      'context' => dict['foo' => 'bar'],
      'datetime' => new DateTimeImmutable(),
      'extra' => dict['foo' => 'xbar'],
      'message' => 'log',
    ));
    expect('bar => xbar')->toBeSame($message);
  }

  public function testDefFormatWithObject(): void {
    $formatter = new HackLogging\Formatter\LineFormatter(
      HackLogging\Formatter\LineFormatter::SIMPLE_FORMAT,
      'Y-m-d',
    );

    $memory = new IO\MemoryHandle();

    $message = $formatter->format(shape(
      'level' => HackLogging\LogLevel::ERROR,
      'level_name' => HackLogging\LogLevelName::ERROR,
      'channel' => 'meh',
      'context' => dict[],
      'datetime' => new DateTimeImmutable(),
      'extra' => dict[
        'foo' => new TestFoo(),
        'bar' => new TestBar(),
        'baz' => vec[],
        'res' => $memory,
      ],
      'message' => 'foobar',
    ));

    expect(Str\format(
      '[%s] meh.ERROR: foobar {} {"foo":{"foo":"fooValue"},"bar":{},"baz":[],"res":{}}%s',
      (new DateTimeImmutable())->format('Y-m-d'),
      "\n",
    ))->toBeSame($message);
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
