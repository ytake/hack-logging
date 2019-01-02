<?hh // strict

namespace HackLogging\Handler;

interface HandlerInterface {

  public function isHandling(vec<string> $record): bool;

  public function handle(vec<string> $record): bool;

  public function handleBatch(vec<string> $records): void;

  public function close(): void;
}
