namespace HackLogging\Handler;

use type HackLogging\RecordShape;

abstract class Handler implements HandlerInterface {

  public function handleBatch(
    vec<RecordShape> $_records,
  )[]: void {}

  public async function closeAsync(): Awaitable<void> {
    return;
  }
}
