namespace HackLogging;

use type InvalidArgumentException;
use type DateTimeZone;
use type Usox\Log\LoggerInterface;
use type Usox\Log\LogLevel;
use type Usox\Log\LogLevelNameMap;
use namespace HH\Lib\{C, Vec, Str};
use namespace HackLogging\Handler;
use function date_default_timezone_get;

final class Logger implements LoggerInterface {

  protected bool $microsecondTimestamps = true;
  protected DateTimeZone $timezone;
  protected vec<Handler\HandlerInterface> $handlers = vec[];

  public function __construct(
    protected string $name,
    vec<Handler\HandlerInterface> $handlers = vec[],
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

  public function useMicrosecondTimestamps(bool $micro): void {
    $this->microsecondTimestamps = $micro;
  }

  private async function writeAsync(
    LogLevel $level,
    string $message,
    dict<arraykey, mixed> $context = dict[]
  ): Awaitable<void> {
    $handlerKey = null;

    foreach ($this->handlers as $key => $handler) {
      if ($handler->isHandling(shape('level' => $level, 'channel' => $this->name))) {
        $handlerKey = $key;
        break;
      }
    }
    if (!$handlerKey is nonnull) {
      return;
    }

    $record = shape(
      'message' => $message,
      'context' => $context,
      'level' => $level,
      'level_name' => LogLevelNameMap::mapLevelToName($level),
      'channel' => $this->name,
      'datetime' => new DateTimeImmutable($this->microsecondTimestamps, $this->timezone),
      'extra' => dict[],
    );
    try {
      $this->handlers = vec($this->handlers);
      await \HH\Asio\vf($this->handlers, ($v) ==> ($v->handleAsync($record)));
    } catch (\Throwable $e) {
    }
  }

  public function reset(): void {
    foreach ($this->handlers as $handler) {
      if ($handler is ResettableInterface) {
        $handler->reset();
      }
    }
  }

  public function emergency(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::EMERGENCY, $message, $context);
  }

  public function alert(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::ALERT, $message, $context);
  }

  public function critical(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::ALERT, $message, $context);
  }

  public function error(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::ERROR, $message, $context);
  }

  public function warning(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::WARNING, $message, $context);
  }

  public function notice(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::NOTICE, $message, $context);
  }

  public function info(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::INFO, $message, $context);
  }

  public function debug(string $message, dict<arraykey,mixed> $context = dict[]): void {
    $this->log(LogLevel::DEBUG, $message, $context);
  }

  public function log(LogLevel $level, string $message, dict<arraykey,mixed> $context = dict[]): void {
    \HH\Asio\join(
      $this->writeAsync(
        $level,
        $message,
        $context
      )
    );
  }
}
