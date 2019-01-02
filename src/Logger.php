<?hh // strict

namespace HackLogging;

use type DateTimeZone;
use namespace HH\Lib\Vec;
use namespace HackLogging\Handler;
use function date_default_timezone_get;

class Logger {

  protected static dict<LogLevel, string> $levels = dict[
    LogLevel::DEBUG     => 'DEBUG',
    LogLevel::INFO      => 'INFO',
    LogLevel::NOTICE    => 'NOTICE',
    LogLevel::WARNING   => 'WARNING',
    LogLevel::ERROR     => 'ERROR',
    LogLevel::CRITICAL  => 'CRITICAL',
    LogLevel::ALERT     => 'ALERT',
    LogLevel::EMERGENCY => 'EMERGENCY',
  ];

  protected DateTimeZone $timezone;
  protected vec<Handler\HandlerInterface> $handlers = vec[];

  public function __construct(
    protected string $name, 
    vec<Handler\HandlerInterface> $handlers = vec[], 
    // array $processors = [], 
    ?DateTimeZone $timezone = null,
  ) {
      // $this->processors = $processors;
    $this->timezone = $timezone ?: new DateTimeZone(date_default_timezone_get() ?: 'UTC');
    $this->setHandlers($handlers);
  }

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

  public function getHandlers(): vec<Handler\HandlerInterface> {
    return $this->handlers;
  }
}
