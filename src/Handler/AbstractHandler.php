<?hh // strict

namespace HackLogging\Handler;

use HackLogging\Logger;
use HackLogging\LogLevel;
use HackLogging\RecordShape;
use HackLogging\ResettableInterface;

abstract class AbstractHandler extends Handler implements ResettableInterface {

  public function __construct(
    protected LogLevel $level = LogLevel::DEBUG,
    protected bool $bubble = true
  ) {
    $this->bubble = $bubble;
  }

  public function isHandling(RecordShape $record): bool {
    return $record['level'] >= $this->level;
  }

  public function getLevel(): LogLevel {
    return $this->level;
  }

  public function setBubble(bool $bubble): void {
    $this->bubble = $bubble;
  }

  public function getBubble(): bool {
    return $this->bubble;
  }

  public function reset(): void {
  }
}
