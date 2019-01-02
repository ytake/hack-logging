<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\RecordShape;

interface HandlerInterface {

  public function isHandling(RecordShape $record): bool;

  public function handle(RecordShape $record): bool;

  public function handleBatch(vec<RecordShape> $records): void;

  public function close(): void;
}
