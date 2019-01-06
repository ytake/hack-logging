<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\RecordShape;
use namespace HH\Asio;

abstract class Handler implements HandlerInterface {

  public function handleBatch(vec<RecordShape> $records): void {
    /*
    foreach ($records as $record) {
      $this->handle($record);
    }
    */
  }

  public async function closeAsync(): Awaitable<void> {
    return;
  }
}
