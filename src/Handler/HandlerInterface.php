<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\RecordShape;

interface HandlerInterface {

  public function isHandling(RecordShape $record): bool;

  public function handleAsync(RecordShape $record): Awaitable<bool>;

  public function handleBatch(vec<RecordShape> $records): void;

  public function closeAsync(): Awaitable<void>;
}
