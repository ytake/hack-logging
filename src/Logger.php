<?hh // strict

namespace HackLogging;

use type InvalidArgumentException;
use type DateTimeZone;
use namespace HH\Lib\{C, Vec, Str};
use namespace HackLogging\Handler;
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
    protected vec<Processor\ProcessorInterface> $processors = vec[],
    ?DateTimeZone $timezone = null,
  ) {
    $this->timezone = $timezone ?: new DateTimeZone(date_default_timezone_get() ?: 'UTC');
    $this->setHandlers($handlers);
  }

  <<__Rx>>
  public function getName(): string {
    return $this->name;
  }

  public function setHandlers(
    vec<Handler\HandlerInterface> $handlers
  ): this {
    $this->handlers = vec[];
    foreach (Vec\reverse($handlers) as $handler) {
      $this->pushHandler($handler);
    }
    return $this;
  }

  public function pushHandler(
    Handler\HandlerInterface $handler
  ): this {
    $this->handlers = Vec\concat(vec[$handler], $this->handlers);
    return $this;
  }
  
  <<__Rx>>
  public function getHandlers(): vec<Handler\HandlerInterface> {
    return $this->handlers;
  }

  /**
   * @throws \HH\InvariantException
   */
  public function popHandler(): Handler\HandlerInterface {
    $handler = C\firstx($this->handlers);
    $this->handlers = Vec\drop($this->handlers, 1);
    return $handler;
  }

  public function pushProcessor(
    Processor\ProcessorInterface $processor
  ): this {
    $this->processors = Vec\concat(vec[$processor], $this->processors);
    return $this;
  }

  public function popProcessor(): Processor\ProcessorInterface {
    $processor = C\firstx($this->processors);
    $this->processors = Vec\drop($this->processors, 1);
    return $processor;
  }

  <<__Rx>>
  public function getProcessors(): vec<Processor\ProcessorInterface> {
    return $this->processors;
  }

  public function useMicrosecondTimestamps(bool $micro): void {
    $this->microsecondTimestamps = $micro;
  }
  
  <<__Rx, __Memoize>>
  public static function getLevelName(LogLevel $level): LogLevelName {
    return static::$levels->at($level);
  }

  public async function write(
    LogLevel $level,
    string $message,
    dict<arraykey, mixed> $context = dict[]
  ): Awaitable<bool> {
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
      'extra' => dict[],
    );
    try {
      foreach ($this->processors as $processor) {
        $record = $processor->invoke($record);
      }
      \reset(&$this->handlers);
      while ($handlerKey !== \key(&$this->handlers)) {
        \next(&$this->handlers);
      }

      while ($handler = \current(&$this->handlers)) {
        if (true === $handler->handle($record)) {
          break;
        }
        \next(&$this->handlers);
      }
    } catch (\Throwable $e) {        
    }
    return true;
  }
}
