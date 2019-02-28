namespace HackLogging\Handler;

use type HackLogging\RecordShape;
use namespace HH\Asio;

abstract class Handler implements HandlerInterface {

  public function handleBatch(vec<RecordShape> $records): void {

  }

  public async function closeAsync(): Awaitable<void> {
    return;
  }
}
