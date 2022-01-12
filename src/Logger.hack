namespace HackLogging;

use namespace HH\Lib\{C, Vec};
use type DateTimeZone;
use function date_default_timezone_get;

class Logger {
  protected static ImmMap<LogLevel, LogLevelName> $levels = ImmMap{
    LogLevel::DEBUG     => LogLevelName::DEBUG,
    LogLevel::INFO      => LogLevelName::INFO,
    LogLevel::NOTICE    => LogLevelName::NOTICE,
    LogLevel::WARNING   => LogLevelName::WARNING,
    LogLevel::ERROR     => LogLevelName::ERROR,
    LogLevel::CRITICAL  => LogLevelName::CRITICAL,
    LogLevel::ALERT     => LogLevelName::ALERT,
    LogLevel::EMERGENCY => LogLevelName::EMERGENCY,
  };

  protected bool $microsecondTimestamps = true;
  protected DateTimeZone $timezone;
  protected vec<Handler\HandlerInterface> $handlers = vec[];

  public function __construct(
    protected string $name,
    vec<Handler\HandlerInterface> $handlers = vec[],
    ?DateTimeZone $timezone = null,
  )[rx] {
    $this->timezone = $timezone ?: new DateTimeZone(date_default_timezone_get() ?: 'UTC');
    $this->setHandlers($handlers);
  }

  public function getName()[]: string {
    return $this->name;
  }

  public function setHandlers(
    vec<Handler\HandlerInterface> $handlers,
  )[write_props]: this {
    $this->handlers = vec[];
    foreach (Vec\reverse($handlers) as $handler) {
      $this->pushHandler($handler);
    }
    return $this;
  }

  public function pushHandler(
    Handler\HandlerInterface $handler,
  )[write_props]: this {
    $this->handlers = Vec\concat(vec[$handler], $this->handlers);
    return $this;
  }

  public function getHandlers()[]: vec<Handler\HandlerInterface> {
    return $this->handlers;
  }

  /**
   * @throws \HH\InvariantException
   */
  public function popHandler()[write_props]: Handler\HandlerInterface {
    $handler = C\firstx($this->handlers);
    $this->handlers = Vec\drop($this->handlers, 1);
    return $handler;
  }

  public function useMicrosecondTimestamps(
    bool $micro,
  )[write_props]: void {
    $this->microsecondTimestamps = $micro;
  }

  <<__Memoize>>
  public static function getLevelName(
    LogLevel $level,
  )[globals]: LogLevelName {
    return static::$levels->at($level);
  }

  public async function writeAsync(
    LogLevel $level,
    string $message,
    dict<arraykey, mixed> $context = dict[],
    dict<arraykey, mixed> $extra = dict[],
  )[globals, rx]: Awaitable<bool> {
    $handlerKey = null;

    $levelName = static::getLevelName($level);
    foreach ($this->handlers as $key => $handler) {
      if ($handler->isHandling(shape('level' => $level, 'channel' => $this->name))) {
        $handlerKey = $key;
        break;
      }
    }
    if (!$handlerKey is nonnull) {
      return false;
    }

    $record = shape(
      'message' => $message,
      'context' => $context,
      'level' => $level,
      'level_name' => $levelName,
      'channel' => $this->name,
      'datetime' => new DateTimeImmutable($this->microsecondTimestamps, $this->timezone),
      'extra' => $extra,
    );
    try {
      $this->handlers = vec($this->handlers);
      $r = await \HH\Asio\vf($this->handlers, ($v) ==> ($v->handleAsync($record)));
      return !C\is_empty($r);
    } catch (\Throwable $e) {
      throw $e;
    }
    return true;
  }

  public function reset()[]: void {
    foreach ($this->handlers as $handler) {
      if ($handler is ResettableInterface) {
        $handler->reset();
      }
    }
  }
}
