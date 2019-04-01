namespace HackLogging\Handler;

use type HackLogging\LogLevel;
use type HackLogging\RecordShape;
use namespace HH\Lib\Experimental\Filesystem;

class FilesystemHandler extends AbstractProcessingHandler {

  public function __construct(
    private Filesystem\FileWriteHandle $writeHandler,
    protected LogLevel $level = LogLevel::DEBUG,
    protected bool $bubble = true,
    protected ?int $filePermission = null,
    protected ?Filesystem\FileLockType $fileLockType = null
  ) {
    parent::__construct($level, $bubble);
  }

  <<__Override>>
  public async function closeAsync(): Awaitable<void> {
    return await $this->writeHandler->closeAsync();
  }

  <<__Override>>
  protected async function writeAsync(RecordShape $record): Awaitable<void> {
    $formatted = Shapes::idx($record, 'formatted', '');
    if($this->fileLockType is nonnull) {
      using ($fl = new Filesystem\FileLock($this->writeHandler, $this->fileLockType)) {
        await $this->writeHandler->writeAsync($formatted);
      }
    }
    await $this->writeHandler->writeAsync($formatted);
  }
}
