<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\RecordShape;

abstract class Handler implements HandlerInterface {

  public function handleBatch(vec<RecordShape> $records): void {
    foreach ($records as $record) {
      $this->handle($record);
    }
  }

  public function close(): void {}

  public function __dispose(): void {
    try {
      $this->close();
    } catch (\Throwable $e) {
      // nothing
    }
  }
}
