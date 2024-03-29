unit DU_GraphicCompression_Tests;

interface

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}

uses
  SysUtils,
  {$IFNDEF FPC}
  TestFramework,
  {$ELSE}
  fpcunit, testregistry,
  {$ENDIF}
  GraphicCompression,
  gexXCF
  ;


type
  TCompressionTestsBase = class(TTestCase)
  private
    FDecompressBuffer: Pointer;
  public
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestCompressedSizeLimits(ADecoder: TDecoder);
    procedure TestDecompressedSizeLimits(ADecoder: TDecoder);
    procedure TestDecompress(ADecoder: TDecoder; Source: Pointer; SrcSize, DestSize: Integer;
      SrcExpected, DestExpected: Integer; StatusExpected: TDecoderStatus; TestNumber: Cardinal);
  published
  end;

  TTGARLEDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder8: TTargaRLEDecoder;
    FDecoder16: TTargaRLEDecoder;
    FDecoder24: TTargaRLEDecoder;
    FDecoder32: TTargaRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompress1Byte8bits;
    procedure TestDecompress1Byte16bits;
    procedure TestDecompress1Byte24bits;
    procedure TestDecompress1Byte32bits;
    procedure TestDecompressMove8Bits;
    procedure TestDecompressFill8Bits;
    procedure TestDecompressMove16Bits;
    procedure TestDecompressFill16Bits;
    procedure TestDecompressMove24Bits;
    procedure TestDecompressFill24Bits;
    procedure TestDecompressMove32Bits;
    procedure TestDecompressFill32Bits;
  end;

  TPackbitsDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TPackbitsRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompress1Byte;
    procedure TestDecompressFill;
    procedure TestDecompressMove;
  end;

  TPSPRLEDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TPSPRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompress1Byte;
    procedure TestDecompress2Bytes;
    procedure TestDecompress3Bytes;
    procedure TestDecompressOutputMove;
    procedure TestDecompressOutputFill;
    procedure TestDecompressOutputMixed;
  end;

  TPCXRLEDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TPCXRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompress1Byte;
    procedure TestDecompressFill;
    procedure TestDecompressCopy;
  end;

  TSGIRLEDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder8: TSGIRLEDecoder;
    FDecoder16: TSGIRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompress1Byte8;
    procedure TestDecompress1Byte16;
    procedure TestDecompressFill8;
    procedure TestDecompressFill16;
    procedure TestDecompressMove8;
    procedure TestDecompressMove16;
  end;

  TRLADecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TRLADecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompress1Byte;
    procedure TestDecompressFill;
    procedure TestDecompressMove;
  end;

  TCutRLEDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TCUTRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompress1Byte0;
    procedure TestDecompress1ByteFF;
    procedure TestDecompress1Byte03;
    procedure TestDecompress2BytesFF64;
    procedure TestDecompress3BytesFF6400;
    procedure TestDecompress2BytesFF64Buffer126;
    procedure TestDecompress4Bytes03xx;
    procedure TestDecompress4Bytes03xx00;
    procedure TestDecompress4Bytes03xxBuffer2;
  end;

  TAmigaRGBDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder16: TAmigaRGBDecoder;
    FDecoder32: TAmigaRGBDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompressIncomplete16;
    procedure TestDecompressIncomplete32;
    procedure TestDecompressFill16;
    procedure TestDecompressFill32;
  end;

  TVDATRLEDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TVDATRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompressCommands;
  end;

  // Only minimal tests here since it's a lot more difficult to manually
  // prepare test data for this. Instead we use our collection of test images
  // including fuzzed ones to check for problems in the decoder.
  TGIFLZWDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TGIFLZWDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
  end;

  // Since LZ77 already has its own error codes it is not using DecoderStatus.
  // Only minimal tests here since it's a lot more difficult to manually
  // prepare test data for this. Instead we use our collection of test images
  // including fuzzed ones to check for problems in the decoder.
  // We are also using zlib for this which is a well tested library.
  TLZ77DecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TLZ77Decoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
  end;

  // Gimp XCF RLE decoder
  TXcfRLEDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder1: TXcfRLEDecoder;
    FDecoder4: TXcfRLEDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompressIncomplete1;
    procedure TestDecompressMove1;
    procedure TestDecompressFill1;
  end;

  // Gimp Dummy decoder
  TXcfNoCompressionDecoderTests = class(TCompressionTestsBase)
  private
    FDecoder: TXcfNoCompressionDecoder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCompressedSize0;
    procedure TestDecompressedSize0;
    procedure TestDecompressedMove;
  end;



implementation

uses ZLibDelphi;

const
  BUFSIZE = 1024; // Size of decompression buffer.

// ********** TCompressionTestsBase **********

procedure TCompressionTestsBase.SetUp;
begin
  GetMem(FDecompressBuffer, BUFSIZE);
end;

procedure TCompressionTestsBase.TearDown;
begin
  FreeMem(FDecompressBuffer);
end;

function GetDecodingStatusAsString(AStatus: TDecoderStatus): string;
begin
  case AStatus of
    dsNotUsed: Result := 'dsNotUsed';
    dsNotInitialized: Result := 'dsNotInitialized';
    dsInitializationError: Result := 'dsInitializationError';
    dsOK: Result := 'dsOK';
    dsNotEnoughInput: Result := 'dsNotEnoughInput';
    dsOutputBufferTooSmall: Result := 'dsOutputBufferTooSmall';
    dsInvalidInput: Result := 'dsInvalidInput';
    dsBufferOverflow: Result := 'dsBufferOverflow';
    dsInvalidBufferSize: Result := 'dsInvalidBufferSize';
  else
    Result := 'Invalid status';
  end;
end;

procedure TCompressionTestsBase.TestCompressedSizeLimits(ADecoder: TDecoder);
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  InputBuffer[0] := 0;
  Source := @InputBuffer;
  // Test for zero length input buffer
  ADecoder.Decode(Source, FDecompressBuffer, 0, 100);
  Check(ADecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [ADecoder.CompressedBytesAvailable]));
  Check(ADecoder.DecoderStatus = dsInvalidBufferSize,
    Format('Decoding status not dsInvalidBufferSize but %s.',
    [GetDecodingStatusAsString(ADecoder.DecoderStatus)]));
  // Test for negative length input buffer
  ADecoder.Decode(Source, FDecompressBuffer, -1, 100);
  Check(ADecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [ADecoder.CompressedBytesAvailable]));
  Check(ADecoder.DecoderStatus = dsInvalidBufferSize,
    Format('Decoding status not dsInvalidBufferSize but %s.',
    [GetDecodingStatusAsString(ADecoder.DecoderStatus)]));
end;

procedure TCompressionTestsBase.TestDecompress(ADecoder: TDecoder; Source: Pointer; SrcSize, DestSize: Integer;
  SrcExpected, DestExpected: Integer; StatusExpected: TDecoderStatus; TestNumber: Cardinal);
begin
  ADecoder.Decode(Source, FDecompressBuffer, SrcSize, DestSize);
  // There should be SrcExpected bytes available
  Check(ADecoder.CompressedBytesAvailable = SrcExpected, Format('Compressed bytes not %d but %d in test %d',
    [SrcExpected, ADecoder.CompressedBytesAvailable, TestNumber]));
  // There should be DestExpected bytes decompressed
  Check(ADecoder.DecompressedBytes = DestExpected, Format('Decompressed bytes not %d but %d in test %d',
    [DestExpected, ADecoder.DecompressedBytes, TestNumber]));
  // Status should be dsOK
  Check(ADecoder.DecoderStatus = StatusExpected,
    Format('Decoding status not %s but %s in test %d.',
    [GetDecodingStatusAsString(StatusExpected),
    GetDecodingStatusAsString(ADecoder.DecoderStatus), TestNumber]));
end;

procedure TCompressionTestsBase.TestDecompressedSizeLimits(ADecoder: TDecoder);
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  InputBuffer[0] := 0;
  Source := @InputBuffer;
  // Test for zero length output buffer
  ADecoder.Decode(Source, FDecompressBuffer, 1, 0);
  Check(ADecoder.DecompressedBytes = 0, Format('Decompressed bytes not 0 but %d',
    [ADecoder.DecompressedBytes]));
  Check(ADecoder.DecoderStatus = dsInvalidBufferSize,
    Format('Decoding status not dsInvalidBufferSize but %s.',
    [GetDecodingStatusAsString(ADecoder.DecoderStatus)]));
  // Test for negative length output buffer
  ADecoder.Decode(Source, FDecompressBuffer, 1, -1);
  Check(ADecoder.DecompressedBytes = 0, Format('Decompressed bytes not 0 but %d',
    [ADecoder.DecompressedBytes]));
  Check(ADecoder.DecoderStatus = dsInvalidBufferSize,
    Format('Decoding status not dsInvalidBufferSize but %s.',
    [GetDecodingStatusAsString(ADecoder.DecoderStatus)]));
end;

// ********** TTGARLEDecoderTests **********

procedure TTGARLEDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder8 := TTargaRLEDecoder.Create(8);
  FDecoder16 := TTargaRLEDecoder.Create(16);
  FDecoder24 := TTargaRLEDecoder.Create(24);
  FDecoder32 := TTargaRLEDecoder.Create(32);
end;

procedure TTGARLEDecoderTests.TearDown;
begin
  FDecoder8.Free;
  FDecoder16.Free;
  FDecoder24.Free;
  FDecoder32.Free;
  inherited TearDown;
end;

procedure TTGARLEDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder8);
  TestCompressedSizeLimits(FDecoder16);
  TestCompressedSizeLimits(FDecoder24);
  TestCompressedSizeLimits(FDecoder32);
end;

procedure TTGARLEDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder8);
  TestDecompressedSizeLimits(FDecoder16);
  TestDecompressedSizeLimits(FDecoder24);
  TestDecompressedSizeLimits(FDecoder32);
end;

procedure TTGARLEDecoderTests.TestDecompress1Byte8bits;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0;
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 0;
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 5);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);
end;

procedure TTGARLEDecoderTests.TestDecompress1Byte16bits;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0;
  TestDecompress(FDecoder16, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder16, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder16, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder16, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 0;
  TestDecompress(FDecoder16, Source, 1, 1, 0, 0, dsNotEnoughInput, 5);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder16, Source, 1, 1, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder16, Source, 1, 1, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder16, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);
end;

procedure TTGARLEDecoderTests.TestDecompress1Byte24bits;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0;
  TestDecompress(FDecoder24, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder24, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder24, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder24, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 0;
  TestDecompress(FDecoder24, Source, 1, 1, 0, 0, dsNotEnoughInput, 5);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder24, Source, 1, 1, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder24, Source, 1, 1, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder24, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);
end;

procedure TTGARLEDecoderTests.TestDecompress1Byte32bits;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0;
  TestDecompress(FDecoder32, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder32, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder32, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder32, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 0;
  TestDecompress(FDecoder32, Source, 1, 1, 0, 0, dsNotEnoughInput, 5);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder32, Source, 1, 1, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder32, Source, 1, 1, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder32, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);
end;

procedure TTGARLEDecoderTests.TestDecompressMove8Bits;
var InputBuffer: array [0..128] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Move for bytes <= $7F
  InputBuffer[0] := 0; // Move 1 byte
  InputBuffer[1] := $ab;
  TestDecompress(FDecoder8, Source, 2, 1, 0, 1, dsOK, 1);
  InputBuffer[0] := 1; // Move 2 bytes
  InputBuffer[2] := $cd;
  TestDecompress(FDecoder8, Source, 3, 2, 0, 2, dsOK, 2);
  InputBuffer[0] := 127; // Move 128 bytes
  for i := 1 to 128 do
    InputBuffer[i] := 255-i;
  TestDecompress(FDecoder8, Source, 129, 128, 0, 128, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 127 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[i+1],
      Format('Unexpected decompressed byte at position %d', [i]));
  TestDecompress(FDecoder8, Source, 129, 127, 1, 127, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder8, Source, 128, 128, 0, 127, dsNotEnoughInput, 5);
  TestDecompress(FDecoder8, Source, 129, 129, 0, 128, dsNotEnoughInput, 6);
end;

procedure TTGARLEDecoderTests.TestDecompressFill8Bits;
var InputBuffer: array [0..128] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Fill for bytes > $7F
  InputBuffer[0] := 128; // Fill 1 byte
  InputBuffer[1] := $ab;
  TestDecompress(FDecoder8, Source, 2, 1, 0, 1, dsOK, 1);
  InputBuffer[0] := 129; // Fill 2 bytes
  InputBuffer[1] := $cd;
  TestDecompress(FDecoder8, Source, 2, 2, 0, 2, dsOK, 2);
  InputBuffer[0] := 255; // Fill 128 bytes
  InputBuffer[1] := $ef;
  TestDecompress(FDecoder8, Source, 2, 128, 0, 128, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 127 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[1],
      Format('Unexpected decompressed word at position %d', [i]));
  TestDecompress(FDecoder8, Source, 2, 127, 0, 127, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder8, Source, 1, 128, 0, 0, dsNotEnoughInput, 5);
  TestDecompress(FDecoder8, Source, 2, 129, 0, 128, dsNotEnoughInput , 6);
end;

procedure TTGARLEDecoderTests.TestDecompressMove16Bits;
var InputBuffer: array [0..256] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Move for bytes <= $7F
  InputBuffer[0] := 0; // Move 1 pixel = 2 bytes
  InputBuffer[1] := $ab;
  InputBuffer[2] := $cd;
  TestDecompress(FDecoder16, Source, 3, 2, 0, 2, dsOK, 1);
  InputBuffer[0] := 1; // Move 2 pixels = 4 bytes
  InputBuffer[3] := $aa;
  InputBuffer[4] := $bb;
  TestDecompress(FDecoder16, Source, 5, 4, 0, 4, dsOK, 2);
  InputBuffer[0] := 127; // Move 128 pixels = 256 bytes
  for i := 1 to 256 do
    InputBuffer[i] := 256-i;
  TestDecompress(FDecoder16, Source, 257, 256, 0, 256, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 255 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[i+1],
      Format('Unexpected decompressed byte at position %d', [i]));
  TestDecompress(FDecoder16, Source, 257, 255, 1, 255, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder16, Source, 256, 256, 0, 255, dsNotEnoughInput, 5);
  TestDecompress(FDecoder16, Source, 257, 257, 0, 256, dsNotEnoughInput, 6);
end;

procedure TTGARLEDecoderTests.TestDecompressFill16Bits;
var InputBuffer: array [0..2] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Fill for bytes > $7F
  InputBuffer[0] := 128; // Fill 1 pixel = 2 bytes
  InputBuffer[1] := $ab;
  InputBuffer[2] := $ba;
  TestDecompress(FDecoder16, Source, 3, 2, 0, 2, dsOK, 1);
  InputBuffer[0] := 129; // Fill 2 pixels = 4 bytes
  TestDecompress(FDecoder16, Source, 3, 4, 0, 4, dsOK, 2);
  InputBuffer[0] := 255; // Fill 128 pixels = 256 bytes
  TestDecompress(FDecoder16, Source, 3, 256, 0, 256, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 127 do
    Check(PWordArray(FDecompressBuffer)^[i] = PWord(@InputBuffer[1])^,
      Format('Unexpected decompressed word at position %d', [i]));
  TestDecompress(FDecoder16, Source, 3, 255, 0, 255, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder16, Source, 2, 256, 1, 0, dsNotEnoughInput, 5);
  TestDecompress(FDecoder16, Source, 1, 256, 0, 0, dsNotEnoughInput, 6);
  TestDecompress(FDecoder16, Source, 3, 257, 0, 256, dsNotEnoughInput, 7);
end;

procedure TTGARLEDecoderTests.TestDecompressMove24Bits;
var InputBuffer: array [0..384] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Move for bytes <= $7F
  InputBuffer[0] := 0; // Move 1 pixel = 3 bytes
  InputBuffer[1] := $ab;
  InputBuffer[2] := $cd;
  InputBuffer[3] := $ef;
  TestDecompress(FDecoder24, Source, 4, 3, 0, 3, dsOK, 1);
  InputBuffer[0] := 1; // Move 2 pixels = 6 bytes
  InputBuffer[4] := $aa;
  InputBuffer[5] := $bb;
  InputBuffer[6] := $cc;
  TestDecompress(FDecoder24, Source, 7, 6, 0, 6, dsOK, 2);
  InputBuffer[0] := 127; // Move 128 pixels = 384 bytes
  for i := 1 to 384 do
    InputBuffer[i] := i div 3;
  TestDecompress(FDecoder24, Source, 385, 384, 0, 384, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 383 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[i+1],
      Format('Unexpected decompressed byte at position %d', [i]));
  TestDecompress(FDecoder24, Source, 385, 383, 1, 383, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder24, Source, 384, 384, 0, 383, dsNotEnoughInput, 5);
  TestDecompress(FDecoder24, Source, 385, 385, 0, 384, dsNotEnoughInput, 6);
end;

procedure TTGARLEDecoderTests.TestDecompressFill24Bits;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Fill for bytes > $7F
  InputBuffer[0] := 128; // Fill 1 pixel = 3 bytes
  InputBuffer[1] := $ab;
  InputBuffer[2] := $ba;
  InputBuffer[3] := $ef;
  TestDecompress(FDecoder24, Source, 4, 3, 0, 3, dsOK, 1);
  InputBuffer[0] := 129; // Fill 2 pixels = 6 bytes
  TestDecompress(FDecoder24, Source, 4, 6, 0, 6, dsOK, 2);
  InputBuffer[0] := 255; // Fill 128 pixels = 384 bytes
  TestDecompress(FDecoder24, Source, 4, 384, 0, 384, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 383 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[i mod 3 + 1],
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder24, Source, 4, 383, 0, 383, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder24, Source, 3, 384, 2, 0, dsNotEnoughInput, 5);
  TestDecompress(FDecoder24, Source, 2, 384, 1, 0, dsNotEnoughInput, 6);
  TestDecompress(FDecoder24, Source, 1, 384, 0, 0, dsNotEnoughInput, 7);
  TestDecompress(FDecoder24, Source, 4, 385, 0, 384, dsNotEnoughInput, 8);
end;

procedure TTGARLEDecoderTests.TestDecompressMove32Bits;
var InputBuffer: array [0..512] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Move for bytes <= $7F
  InputBuffer[0] := 0; // Move 1 pixel = 4 bytes
  InputBuffer[1] := $ab;
  InputBuffer[2] := $cd;
  InputBuffer[3] := $01;
  InputBuffer[4] := $23;
  TestDecompress(FDecoder32, Source, 5, 4, 0, 4, dsOK, 1);
  InputBuffer[0] := 1; // Move 2 pixels = 8 bytes
  InputBuffer[5] := $1b;
  InputBuffer[6] := $2d;
  InputBuffer[7] := $31;
  InputBuffer[8] := $43;
  TestDecompress(FDecoder32, Source, 9, 8, 0, 8, dsOK, 2);
  InputBuffer[0] := 127; // Move 128 pixels = 512 bytes
  for i := 1 to 512 do
    InputBuffer[i] := i mod 256;
  TestDecompress(FDecoder32, Source, 513, 512, 0, 512, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 511 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[i+1],
      Format('Unexpected decompressed byte at position %d', [i]));
  TestDecompress(FDecoder32, Source, 513, 511, 1, 511, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder32, Source, 512, 512, 0, 511, dsNotEnoughInput, 5);
  TestDecompress(FDecoder32, Source, 513, 513, 0, 512, dsNotEnoughInput, 6);
end;

procedure TTGARLEDecoderTests.TestDecompressFill32Bits;
var InputBuffer: array [0..4] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer;
  // TGA RLE does Fill for bytes > $7F
  InputBuffer[0] := 128; // Fill 1 pixel = 4 bytes
  InputBuffer[1] := $ab;
  InputBuffer[2] := $ba;
  InputBuffer[3] := $98;
  InputBuffer[4] := $76;
  TestDecompress(FDecoder32, Source, 5, 4, 0, 4, dsOK, 1);
  InputBuffer[0] := 129; // Fill 2 pixels = 8 bytes
  TestDecompress(FDecoder32, Source, 5, 8, 0, 8, dsOK, 2);
  InputBuffer[0] := 255; // Fill 128 pixels = 512 bytes
  TestDecompress(FDecoder32, Source, 5, 512, 0, 512, dsOK, 3);
  // Check contents of buffer
  for i := 0 to 511 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[i mod 4 + 1],
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder32, Source, 5, 511, 0, 511, dsOutputBufferTooSmall, 4);
  TestDecompress(FDecoder32, Source, 4, 512, 3, 0, dsNotEnoughInput, 5);
  TestDecompress(FDecoder32, Source, 3, 512, 2, 0, dsNotEnoughInput, 6);
  TestDecompress(FDecoder32, Source, 2, 512, 1, 0, dsNotEnoughInput, 7);
  TestDecompress(FDecoder32, Source, 1, 512, 0, 0, dsNotEnoughInput, 8);
  TestDecompress(FDecoder32, Source, 5, 513, 0, 512, dsNotEnoughInput, 9);
end;

// ********** TPackbitsDecoderTests **********

procedure TPackbitsDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder := TPackbitsRLEDecoder.Create;
end;

procedure TPackbitsDecoderTests.TearDown;
begin
  FDecoder.Free;
  inherited TearDown;
end;

procedure TPackbitsDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TPackbitsDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

procedure TPackbitsDecoderTests.TestDecompress1Byte;
var
  Source: Pointer;
  InputBuffer: array [0..0] of ShortInt;
begin
  Source := @InputBuffer;
  InputBuffer[0] := -1; // count = 2, fillchar 2 times
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := -127; // same but count = 128
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := -128; // nop
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 0; // count = 1, move 1 chars
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 127; // same but count = 128, move 128 chars
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 5);

  InputBuffer[0] := -1; // count = 2, fillchar 2 times
  TestDecompress(FDecoder, Source, 1, 2, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := -127; // same but count = 128
  TestDecompress(FDecoder, Source, 1, 128, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := -128; // nop
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 0; // count = 1, move 1 chars
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 127; // same but count = 128, move 128 chars
  TestDecompress(FDecoder, Source, 1, 127, 0, 0, dsNotEnoughInput, 5);
end;

procedure TPackbitsDecoderTests.TestDecompressFill;
var
  Source: Pointer;
  InputBuffer: array [0..1] of ShortInt;
  i: Integer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := -1; // Fill char 2 times
  InputBuffer[1] := 71; // Char to fill n times
  TestDecompress(FDecoder, Source, 2, BUFSIZE, 0, 2, dsNotEnoughInput, 1);
  TestDecompress(FDecoder, Source, 2, 2, 0, 2, dsOk, 2);
  i := 0;
  for i := 0 to 1 do
    Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = InputBuffer[1],
      Format('Unexpected decompressed data at position %d', [i]));

  InputBuffer[0] := -127; // count = 128
  InputBuffer[1] := -81; // Byte to repeatedly fill
  TestDecompress(FDecoder, Source, 2, BUFSIZE, 0, 128, dsNotEnoughInput, 3);
  TestDecompress(FDecoder, Source, 2, 128, 0, 128, dsOk, 4);
  for i := 0 to 127 do
    Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = InputBuffer[1],
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder, Source, 2, 127, 0, 127, dsOutputBufferTooSmall, 5);
  TestDecompress(FDecoder, Source, 3, 128, 1, 128, dsOutputBufferTooSmall, 6);
end;

procedure TPackbitsDecoderTests.TestDecompressMove;
var
  Source: Pointer;
  InputBuffer: array [0..128] of ShortInt;
  i: Integer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0; // Count = 1. Move next 1 bytes.
  InputBuffer[1] := -99;
  TestDecompress(FDecoder, Source, 2, 1, 0, 1, dsOk, 1);
  i := 0;
  Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = InputBuffer[1],
    Format('Unexpected decompressed data at position %d', [i]));
  InputBuffer[0] := 127; // Count = 128. Move next 128 bytes.
  for i := 1 to 128 do
    InputBuffer[i] := i div 2;
  TestDecompress(FDecoder, Source, 129, 128, 0, 128, dsOk, 2);
  for i := 0 to 127 do
    Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = InputBuffer[i+1],
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder, Source, 129, 127, 1, 127, dsOutputBufferTooSmall , 3);
  TestDecompress(FDecoder, Source, 130, 128, 1, 128, dsOutputBufferTooSmall, 4);
end;

// ********** TPSPRLEDecoderTests **********

procedure TPSPRLEDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder := TPSPRLEDecoder.Create;
  FDecoder.DecodeInit; // Not really needed here
end;

procedure TPSPRLEDecoderTests.TearDown;
begin
  FDecoder.DecodeEnd; // Not really needed here
  FDecoder.Free;
  inherited TearDown;
end;

procedure TPSPRLEDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TPSPRLEDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

procedure TPSPRLEDecoderTests.TestDecompress1Byte;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0;
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 0;
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 5);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);
end;

procedure TPSPRLEDecoderTests.TestDecompress2Bytes;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0;
  InputBuffer[1] := 77;
  TestDecompress(FDecoder, Source, 2, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder, Source, 2, 1, 0, 1, dsOK, 2);
  InputBuffer[0] := 2;
  TestDecompress(FDecoder, Source, 2, 2, 1, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := 128;
  TestDecompress(FDecoder, Source, 2, BUFSIZE, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := 129;
  TestDecompress(FDecoder, Source, 2, 1, 0, 1, dsOK, 5);
  InputBuffer[0] := 130;
  TestDecompress(FDecoder, Source, 2, 2, 0, 2, dsOK, 6);
  TestDecompress(FDecoder, Source, 2, 1, 1, 0, dsOutputBufferTooSmall , 7);
  TestDecompress(FDecoder, Source, 3, 2, 1, 2, dsOutputBufferTooSmall , 8);
end;

procedure TPSPRLEDecoderTests.TestDecompress3Bytes;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 2;
  InputBuffer[1] := 77;
  InputBuffer[2] := 66;
  TestDecompress(FDecoder, Source, 3, 2, 0, 2, dsOK, 1);
  TestDecompress(FDecoder, Source, 3, 1, 2, 0, dsOutputBufferTooSmall, 2);
end;

procedure TPSPRLEDecoderTests.TestDecompressOutputMove;
const ExpectedOutput: array [0..4] of byte = (77, 66, 255, 128, 0);
var InputBuffer: array [0..6] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer[0];
  InputBuffer[0] := 2;
  InputBuffer[1] := 77;
  InputBuffer[2] := 66;
  InputBuffer[3] := 3;
  InputBuffer[4] := 255;
  InputBuffer[5] := 128;
  InputBuffer[6] := 0;
  FDecoder.Decode(Source, FDecompressBuffer, 7, 5);
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  Check(FDecoder.DecompressedBytes = 5, Format('Decompressed bytes not 5 but %d',
    [FDecoder.DecompressedBytes]));
  Check(FDecoder.DecoderStatus = dsOK, Format('Decoding status not dsOK but %s.',
    [GetDecodingStatusAsString(FDecoder.DecoderStatus)]));
  for i := 0 to 4 do
    Check(ExpectedOutput[i] = PByteArray(FDecompressBuffer)^[i],
      Format('We expected %d but got %d at position %d',
      [ExpectedOutput[i], PByteArray(FDecompressBuffer)^[i], i]));
end;

procedure TPSPRLEDecoderTests.TestDecompressOutputFill;
const ExpectedOutput: array [0..5] of byte = (77, 255, 255, 128, 128, 128);
var InputBuffer: array [0..5] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer[0];
  InputBuffer[0] := 129;
  InputBuffer[1] := 77;
  InputBuffer[2] := 130;
  InputBuffer[3] := 255;
  InputBuffer[4] := 131;
  InputBuffer[5] := 128;
  FDecoder.Decode(Source, FDecompressBuffer, 6, 6);
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  Check(FDecoder.DecompressedBytes = 6, Format('Decompressed bytes not 6 but %d',
    [FDecoder.DecompressedBytes]));
  Check(FDecoder.DecoderStatus = dsOK, Format('Decoding status not dsOK but %s.',
    [GetDecodingStatusAsString(FDecoder.DecoderStatus)]));
  for i := 0 to 5 do
    Check(ExpectedOutput[i] = PByteArray(FDecompressBuffer)^[i],
      Format('We expected %d but got %d at position %d',
      [ExpectedOutput[i], PByteArray(FDecompressBuffer)^[i], i]));
end;

procedure TPSPRLEDecoderTests.TestDecompressOutputMixed;
const ExpectedOutput: array [0..11] of byte = (77, 77, 1, 8, 4, 4, 4, 6, 3, 255, 254, 253);
var InputBuffer: array [0..12] of byte;
  Source: Pointer;
  i: Integer;
begin
  Source := @InputBuffer[0];
  InputBuffer[0] := 130;
  InputBuffer[1] := 77;
  InputBuffer[2] := 2;
  InputBuffer[3] := 1;
  InputBuffer[4] := 8;
  InputBuffer[5] := 131;
  InputBuffer[6] := 4;
  InputBuffer[7] := 5;
  InputBuffer[8] := 6;
  InputBuffer[9] := 3;
  InputBuffer[10] := 255;
  InputBuffer[11] := 254;
  InputBuffer[12] := 253;
  FDecoder.Decode(Source, FDecompressBuffer, 13, 12);
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  Check(FDecoder.DecompressedBytes = 12, Format('Decompressed bytes not 12 but %d',
    [FDecoder.DecompressedBytes]));
  Check(FDecoder.DecoderStatus = dsOK, Format('Decoding status not dsOK but %s.',
    [GetDecodingStatusAsString(FDecoder.DecoderStatus)]));
  for i := 0 to 11 do
    Check(ExpectedOutput[i] = PByteArray(FDecompressBuffer)^[i],
      Format('We expected %d but got %d at position %d',
      [ExpectedOutput[i], PByteArray(FDecompressBuffer)^[i], i]));
end;

// ********** TPCXRLEDecoderTests **********

procedure TPCXRLEDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder := TPCXRLEDecoder.Create;
end;

procedure TPCXRLEDecoderTests.TearDown;
begin
  FDecoder.Free;
  inherited TearDown;
end;

procedure TPCXRLEDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TPCXRLEDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

procedure TPCXRLEDecoderTests.TestDecompress1Byte;
var
  Source: Pointer;
  InputBuffer: array [0..0] of byte;
begin
  Source := @InputBuffer;
  InputBuffer[0] := $c0; // Lower 6 bits is repeat count of the next byte; count = 0
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := $c1; // same but count = 1
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := $ff; // same but count = 63
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);

  InputBuffer[0] := 0; // Lowest literal byte
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 1, dsNotEnoughInput, 4);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 1, dsNotEnoughInput, 5);
  InputBuffer[0] := $3f; // Highest literal byte
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 1, dsNotEnoughInput, 6);

  InputBuffer[0] := $c0; // Lower 6 bits is repeat count of the next byte; count = 0
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := $c1; // same but count = 1
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);
  InputBuffer[0] := $ff; // same but count = 63
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 9);
end;

procedure TPCXRLEDecoderTests.TestDecompressFill;
var
  Source: Pointer;
  InputBuffer: array [0..10] of byte;
  i: Integer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := $c0; // Lower 6 bits is repeat count of the next byte; count = 0
  InputBuffer[1] := $c1; // Repeat, count = 1
  InputBuffer[2] := $12; // Byte to repeatedly fill
  TestDecompress(FDecoder, Source, 3, BUFSIZE, 0, 1, dsNotEnoughInput, 1);
  TestDecompress(FDecoder, Source, 3, 1, 0, 1, dsOk, 2);
  i := 0;
  Check(PByteArray(FDecompressBuffer)^[i] = $12,
    Format('Unexpected decompressed data at position %d', [i]));

  InputBuffer[0] := $ff; // count = 63
  InputBuffer[1] := $ee; // Byte to repeatedly fill
  TestDecompress(FDecoder, Source, 2, BUFSIZE, 0, 63, dsNotEnoughInput, 3);
  TestDecompress(FDecoder, Source, 2, 63, 0, 63, dsOk, 4);
  for i := 0 to 30 do
    Check(PByteArray(FDecompressBuffer)^[i] = $ee,
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder, Source, 2, 62, 0, 62, dsOutputBufferTooSmall, 5);
  TestDecompress(FDecoder, Source, 3, 63, 1, 63, dsOutputBufferTooSmall, 6);
end;

procedure TPCXRLEDecoderTests.TestDecompressCopy;
var
  Source: Pointer;
  InputBuffer: array [0..0] of byte;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0; // Lowest literal byte
  TestDecompress(FDecoder, Source, 1, 1, 0, 1, dsOk, 1);
  InputBuffer[0] := 1;
  TestDecompress(FDecoder, Source, 1, 1, 0, 1, dsOk, 2);
  InputBuffer[0] := $3f; // Highest literal byte
  TestDecompress(FDecoder, Source, 1, 1, 0, 1, dsOk, 3);
end;

// ********** TSGIRLEDecoderTests **********

procedure TSGIRLEDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder8 := TSGIRLEDecoder.Create(8);
  FDecoder16 := TSGIRLEDecoder.Create(16);
end;

procedure TSGIRLEDecoderTests.TearDown;
begin
  FDecoder8.Free;
  FDecoder16.Free;
  inherited TearDown;
end;

procedure TSGIRLEDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder8);
  TestCompressedSizeLimits(FDecoder16);
end;

procedure TSGIRLEDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder8);
  TestDecompressedSizeLimits(FDecoder16);
end;

procedure TSGIRLEDecoderTests.TestDecompress1Byte8;
var
  Source: Pointer;
  InputBuffer: array [0..0] of byte;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0; // 0 is end of input
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := $80; // $80 is a count of 0 is end of input
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := 0; // 0 is end of input
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := $80; // $80 is a count of 0 is end of input
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 4);

  InputBuffer[0] := $01; // count = 1; Copy next char 1 times
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := $81; // count = 1; Copy next 1 chars
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := $01; // count = 1; Copy next char 1 times
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);
  InputBuffer[0] := $81; // count = 1; Copy next 1 chars
  TestDecompress(FDecoder8, Source, 1, 1, 0, 0, dsNotEnoughInput, 9);

  InputBuffer[0] := $7f; // count = 127; Copy next char 127 times
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 10);
  InputBuffer[0] := $7f; // count = 127; Copy next 127 chars
  TestDecompress(FDecoder8, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 11);
  InputBuffer[0] := $ff; // count = 127; Copy next char 127 times
  TestDecompress(FDecoder8, Source, 1, 127, 0, 0, dsNotEnoughInput, 12);
  InputBuffer[0] := $ff; // count = 127; Copy next 127 chars
  TestDecompress(FDecoder8, Source, 1, 127, 0, 0, dsNotEnoughInput, 13);
end;

procedure TSGIRLEDecoderTests.TestDecompress1Byte16;
var
  Source, Source16: Pointer;
  InputBuffer: array [0..0] of byte;
  // BigEndian words needed so we can't just use an array of word
  InputBuffer16: array [0..2] of byte;
begin
  Source := @InputBuffer;
  Source16 := @InputBuffer16;
  InputBuffer[0] := 0; // 1 byte isn't enough to even read the length
  TestDecompress(FDecoder16, Source, 1, 1, 1, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := $80; // same
  TestDecompress(FDecoder16, Source, 1, 1, 1, 0, dsNotEnoughInput, 2);
  InputBuffer16[0] := 0;
  InputBuffer16[1] := 0;
  TestDecompress(FDecoder16, Source16, 2, 1, 0, 0, dsNotEnoughInput, 3);
  InputBuffer16[0] := 0;
  InputBuffer16[1] := $80;
  TestDecompress(FDecoder16, Source16, 2, 1, 0, 0, dsNotEnoughInput, 4);

  InputBuffer16[0] := 0;
  InputBuffer16[1] := $01; // Copy next word 1 time
  TestDecompress(FDecoder16, Source16, 2, 1, 0, 0, dsNotEnoughInput, 5);
  InputBuffer16[0] := 0;
  InputBuffer16[1] := $81; // Copy next 1 words
  TestDecompress(FDecoder16, Source16, 2, 1, 0, 0, dsNotEnoughInput, 6);

  // Here we use 1 extra input byte that we don't need to initialize.
  InputBuffer16[0] := 0;
  InputBuffer16[1] := $01; // Copy next word 1 time
  TestDecompress(FDecoder16, Source16, 3, 1, 1, 0, dsNotEnoughInput, 7);
  InputBuffer16[0] := 0;
  InputBuffer16[1] := $81; // Copy next 1 words
  TestDecompress(FDecoder16, Source16, 3, 1, 1, 0, dsNotEnoughInput, 8);
end;

procedure TSGIRLEDecoderTests.TestDecompressFill8;
var
  Source: Pointer;
  InputBuffer: array [0..2] of byte;
  i: Integer;
begin
  Source := @InputBuffer[0];
  InputBuffer[0] := 1; // count = 1
  InputBuffer[1] := $aa; // Char to be filled.
  InputBuffer[2] := 0; // 0 is end of input
  // without 0 byte to end input
  TestDecompress(FDecoder8, Source, 2, 1, 0, 1, dsOk, 1);
  // with 0 byte to end input, this byte will not be read
  TestDecompress(FDecoder8, Source, 3, 1, 1, 1, dsOk, 2);

  // Same but with length 127
  InputBuffer[0] := $7f; // count = 127
  TestDecompress(FDecoder8, Source, 2, 127, 0, 127, dsOk, 3);
  for i := 0 to 126 do
    Check(PByteArray(FDecompressBuffer)^[i] = $aa,
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder8, Source, 3, 127, 1, 127, dsOk, 4);

  // Output buffer too small test
  TestDecompress(FDecoder8, Source, 2, 126, 0, 126, dsOutputBufferTooSmall, 5);
  TestDecompress(FDecoder8, Source, 3, 126, 1, 126, dsOutputBufferTooSmall, 6);
  TestDecompress(FDecoder8, Source, 5, 127, 3, 127, dsOutputBufferTooSmall, 7);
end;

procedure TSGIRLEDecoderTests.TestDecompressFill16;
var
  Source: Pointer;
  InputBuffer: array [0..2] of word;  // Note Big Endian!
  i: Integer;
begin
  Source := @InputBuffer[0];
  InputBuffer[0] := $0100; // count = 1
  InputBuffer[1] := $aabb; // Word to be filled.
  InputBuffer[2] := 0; // 0 is end of input
  // without 0 word to end input
  TestDecompress(FDecoder16, Source, 4, 2, 0, 2, dsOk, 1);
  // with 0 word to end input, this byte will not be read
  TestDecompress(FDecoder16, Source, 6, 2, 2, 2, dsOk, 2);

  // Same but with length 127
  InputBuffer[0] := $7f00; // count = 127; bytes = 254
  TestDecompress(FDecoder16, Source, 4, 254, 0, 254, dsOk, 3);
  for i := 0 to 126 do
    Check(PWordArray(FDecompressBuffer)^[i] = $aabb,
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder16, Source, 6, 254, 2, 254, dsOk, 4);

  // Output buffer too small test
  TestDecompress(FDecoder16, Source, 4, 252, 0, 252, dsOutputBufferTooSmall, 5);
  TestDecompress(FDecoder16, Source, 6, 252, 2, 252, dsOutputBufferTooSmall, 6);
  TestDecompress(FDecoder16, Source, 4, 253, 0, 252, dsOutputBufferTooSmall, 7);
  TestDecompress(FDecoder16, Source, 6, 253, 2, 252, dsOutputBufferTooSmall, 8);
  TestDecompress(FDecoder16, Source, 8, 254, 4, 254, dsOutputBufferTooSmall, 9);
end;

procedure TSGIRLEDecoderTests.TestDecompressMove8;
var
  Source: Pointer;
  InputBuffer: array [0..128] of byte;
  i: Integer;
begin
  Source := @InputBuffer[0];
  InputBuffer[0] := $81; // count = 1
  InputBuffer[1] := $aa; // Char to be copied.
  InputBuffer[2] := $00; // 0 is end of input
  // without 0 byte to end input
  TestDecompress(FDecoder8, Source, 2, 1, 0, 1, dsOk, 1);
  // with 0 byte to end input, this byte will not be read
  TestDecompress(FDecoder8, Source, 3, 1, 1, 1, dsOk, 2);

  // Same but with length 127
  InputBuffer[0] := $ff; // count = 127
  for i := 1 to 127 do
    InputBuffer[i] := 255-i;
  InputBuffer[128] := 0;
  TestDecompress(FDecoder8, Source, 128, 127, 0, 127, dsOk, 3);
  for i := 0 to 126 do
    Check(PByteArray(FDecompressBuffer)^[i] = InputBuffer[i+1],
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder8, Source, 129, 127, 1, 127, dsOk, 4);

  // Output buffer too small test
  TestDecompress(FDecoder8, Source, 128, 126, 1, 126, dsOutputBufferTooSmall, 5);
  TestDecompress(FDecoder8, Source, 129, 126, 2, 126, dsOutputBufferTooSmall, 6);
end;

procedure TSGIRLEDecoderTests.TestDecompressMove16;
var
  Source: Pointer;
  InputBuffer: array [0..128] of word;  // Note Big Endian!
  i: Integer;
begin
  Source := @InputBuffer[0];
  InputBuffer[0] := $8100; // count = 1
  InputBuffer[1] := $aabb; // Char to be copied.
  InputBuffer[2] := $0000; // 0 is end of input
  // without 0 byte to end input
  TestDecompress(FDecoder16, Source, 4, 2, 0, 2, dsOk, 1);
  // with 0 byte to end input, this byte will not be read
  TestDecompress(FDecoder16, Source, 6, 2, 2, 2, dsOk, 2);

  // Same but with length 127
  InputBuffer[0] := $ff00; // count = 127 = 254 bytes
  for i := 1 to 127 do
    InputBuffer[i] := i*8;
  InputBuffer[128] := 0;
  TestDecompress(FDecoder16, Source, 256, 254, 0, 254, dsOk, 3);
  for i := 0 to 126 do
    Check(PWordArray(FDecompressBuffer)^[i] = InputBuffer[i+1],
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder16, Source, 258, 254, 2, 254, dsOk, 4);

  // Output buffer too small test
  TestDecompress(FDecoder16, Source, 256, 252, 2, 252, dsOutputBufferTooSmall, 5);
  TestDecompress(FDecoder16, Source, 258, 252, 4, 252, dsOutputBufferTooSmall, 6);
  TestDecompress(FDecoder16, Source, 256, 253, 2, 252, dsOutputBufferTooSmall, 7);
  TestDecompress(FDecoder16, Source, 258, 253, 4, 252, dsOutputBufferTooSmall, 8);
end;

// ********** TRLADecoderTests **********

procedure TRLADecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder := TRLADecoder.Create;
end;

procedure TRLADecoderTests.TearDown;
begin
  FDecoder.Free;
  inherited TearDown;
end;

procedure TRLADecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TRLADecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

procedure TRLADecoderTests.TestDecompress1Byte;
var
  Source: Pointer;
  InputBuffer: array [0..0] of ShortInt;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0; // count = 1, fillchar 1 times
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := 127; // same but count = 128
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := -1; // count = 1, move 1 chars
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  InputBuffer[0] := -128; // same but count = 129, move 129 chars
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 4);

  InputBuffer[0] := 0; // count = 1, fillchar 1 times
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 5);
  InputBuffer[0] := 127; // same but count = 128
  TestDecompress(FDecoder, Source, 1, 128, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := -1; // count = 1, move 1 chars
  TestDecompress(FDecoder, Source, 1, 1, 0, 0, dsNotEnoughInput, 7);
  InputBuffer[0] := -128; // same but count = 128, move 128 chars
  TestDecompress(FDecoder, Source, 1, 128, 0, 0, dsNotEnoughInput, 8);
end;

procedure TRLADecoderTests.TestDecompressFill;
var
  Source: Pointer;
  InputBuffer: array [0..10] of ShortInt;
  i: Integer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := 0;  // Fill char 1 time
  InputBuffer[1] := 17; // Char to fill n times
  TestDecompress(FDecoder, Source, 2, BUFSIZE, 0, 1, dsNotEnoughInput, 1);
  TestDecompress(FDecoder, Source, 2, 1, 0, 1, dsOk, 2);
  i := 0;
  Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = 17,
    Format('Unexpected decompressed data at position %d', [i]));

  InputBuffer[0] := 127; // count = 128
  InputBuffer[1] := -18; // Byte to repeatedly fill
  TestDecompress(FDecoder, Source, 2, BUFSIZE, 0, 128, dsNotEnoughInput, 3);
  TestDecompress(FDecoder, Source, 2, 128, 0, 128, dsOk, 4);
  for i := 0 to 127 do
    Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = -18,
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder, Source, 2, 127, 0, 127, dsOutputBufferTooSmall, 5);
  TestDecompress(FDecoder, Source, 3, 128, 1, 128, dsOutputBufferTooSmall, 6);
end;

procedure TRLADecoderTests.TestDecompressMove;
var
  Source: Pointer;
  InputBuffer: array [0..128] of ShortInt;
  i: Integer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := -1; // Count = 1. Move next 1 bytes
  InputBuffer[1] := -127;
  TestDecompress(FDecoder, Source, 2, 1, 0, 1, dsOk, 1);
  i := 0;
  Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = -127,
    Format('Unexpected decompressed data at position %d', [i]));
  InputBuffer[0] := -128;
  for i := 1 to 128 do
    InputBuffer[i] := i;
  TestDecompress(FDecoder, Source, 129, 128, 0, 128, dsOk, 2);
  for i := 0 to 127 do
    Check(ShortInt(PByteArray(FDecompressBuffer)^[i]) = InputBuffer[i+1],
      Format('Unexpected decompressed data at position %d', [i]));
  TestDecompress(FDecoder, Source, 129, 127, 1, 127, dsOutputBufferTooSmall , 3);
  TestDecompress(FDecoder, Source, 130, 128, 1, 128, dsOutputBufferTooSmall, 4);
end;

// ********** TCutRLEDecoderTests **********
// TODO: The CUT tests need to be revised.

procedure TCutRLEDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder := TCUTRLEDecoder.Create;
  FDecoder.DecodeInit; // Not really needed here
end;

procedure TCutRLEDecoderTests.TearDown;
begin
  FDecoder.DecodeEnd; // Not really needed here
  FDecoder.Free;
  inherited TearDown;
end;

procedure TCutRLEDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TCutRLEDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

procedure TCUTRLEDecoderTests.TestDecompress1Byte0;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  // 0 means end of input, nothing gets decompressed.
  InputBuffer[0] := 0;
  InputBuffer[1] := 0;
  Source := @InputBuffer;
  // 2 bytes input, max 2 bytes output
  FDecoder.Decode(Source, FDecompressBuffer, 2, 2);
  // There should be 1 bytes available
  Check(FDecoder.CompressedBytesAvailable = 1, Format('Compressed bytes not 1 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 0 bytes decompressed
  Check(FDecoder.DecompressedBytes = 0, Format('Decompressed bytes not 0 but %d',
    [FDecoder.DecompressedBytes]));
end;

procedure TCUTRLEDecoderTests.TestDecompress1ByteFF;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  // $ff means copy next byte $7f times
  InputBuffer[0] := $ff;
  Source := @InputBuffer;
  // 1 byte incomplete input should result in 0 bytes output
  FDecoder.Decode(Source, FDecompressBuffer, 1, 128);
  // There should be 0 bytes available
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 0 bytes decompressed
  Check(FDecoder.DecompressedBytes = 0, Format('Decompressed bytes not 0 but %d',
    [FDecoder.DecompressedBytes]));
end;

procedure TCUTRLEDecoderTests.TestDecompress1Byte03;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
  i: Integer;
begin
  // $03 means move next $03 bytes to output
  InputBuffer[0] := $03;
  for i := 0 to 2 do
    InputBuffer[i] := i;
  Source := @InputBuffer;
  // 1 byte incomplete input should result in 0 bytes output
  FDecoder.Decode(Source, FDecompressBuffer, 1, 128);
  // There should be 0 bytes available
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 0 bytes decompressed
  Check(FDecoder.DecompressedBytes = 0, Format('Decompressed bytes not 0 but %d',
    [FDecoder.DecompressedBytes]));
end;

procedure TCUTRLEDecoderTests.TestDecompress2BytesFF64;
var InputBuffer: array [0..1] of byte;
  OutputBuffer: PByte;
  ExpectedValue: Byte;
  Source: Pointer;
  i: Integer;
begin
  // $ff means copy next byte $7f times
  InputBuffer[0] := $ff;
  InputBuffer[1] := $64; // 100
  ExpectedValue := $64;
  Source := @InputBuffer;
  // 2 byte input should result in $7f (127) bytes output (all bytes should be $64)
  FDecoder.Decode(Source, FDecompressBuffer, 2, 128);
  // There should be 0 bytes available
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 127 bytes decompressed
  Check(FDecoder.DecompressedBytes = 127, Format('Decompressed bytes not 127 but %d',
    [FDecoder.DecompressedBytes]));
  OutputBuffer := FDecompressBuffer;
  for i := 0 to 126 do begin
    Check(OutputBuffer^ = ExpectedValue,
      Format('Decompressed byte at index %d has unexpected value %x instead of %x',
      [i, OutputBuffer^, ExpectedValue]));
    Inc(OutputBuffer);
  end;
end;

procedure TCUTRLEDecoderTests.TestDecompress3BytesFF6400;
var InputBuffer: array [0..2] of byte;
  OutputBuffer: PByte;
  ExpectedValue: Byte;
  Source: Pointer;
  i: Integer;
begin
  // $ff means copy next byte $7f times
  InputBuffer[0] := $ff;
  InputBuffer[1] := $64; // 100
  InputBuffer[2] := $00; // end of input
  ExpectedValue := $64;
  Source := @InputBuffer;
  // 3 byte input should result in $7f (127) bytes output (all bytes should be $64)
  FDecoder.Decode(Source, FDecompressBuffer, 3, 128);
  // There should be 0 bytes available
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 127 bytes decompressed
  Check(FDecoder.DecompressedBytes = 127, Format('Decompressed bytes not 127 but %d',
    [FDecoder.DecompressedBytes]));
  OutputBuffer := FDecompressBuffer;
  for i := 0 to 126 do begin
    Check(OutputBuffer^ = ExpectedValue,
      Format('Decompressed byte at index %d has unexpected value %x instead of %x',
      [i, OutputBuffer^, ExpectedValue]));
    Inc(OutputBuffer);
  end;
end;

procedure TCUTRLEDecoderTests.TestDecompress2BytesFF64Buffer126;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  // $ff means copy next byte $7f times
  InputBuffer[0] := $ff;
  InputBuffer[1] := $64; // 100
  Source := @InputBuffer;
  // 2 byte input should result in $7f (127) bytes output but buffer is too small
  FDecoder.Decode(Source, FDecompressBuffer, 2, 126);
  // There should be 1 byte available since we can't handle the count
  Check(FDecoder.CompressedBytesAvailable = 1, Format('Compressed bytes not 1 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be less than 127 bytes decompressed
  Check(FDecoder.DecompressedBytes < 127, Format('Decompressed bytes not smaller than 127 but %d',
    [FDecoder.DecompressedBytes]));
end;

procedure TCUTRLEDecoderTests.TestDecompress4Bytes03xx;
var InputBuffer: array [0..3] of byte;
  OutputBuffer: PByte;
  Source: Pointer;
  i: Integer;
begin
  // $03 means move next $03 bytes to output
  InputBuffer[0] := $03;
  for i := 1 to 3 do
    InputBuffer[i] := i;
  Source := @InputBuffer;
  // 4 bytes input should result in 3 bytes output
  FDecoder.Decode(Source, FDecompressBuffer, 4, 3);
  // There should be 0 bytes available
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 3 bytes decompressed
  Check(FDecoder.DecompressedBytes = 3, Format('Decompressed bytes not 3 but %d',
    [FDecoder.DecompressedBytes]));
  OutputBuffer := FDecompressBuffer;
  for i := 1 to 3 do begin
    Check(OutputBuffer^ = i,
      Format('Decompressed byte at index %d has unexpected value %x instead of %x',
      [i, OutputBuffer^, i]));
    Inc(OutputBuffer);
  end;
end;

procedure TCUTRLEDecoderTests.TestDecompress4Bytes03xx00;
var InputBuffer: array [0..4] of byte;
  OutputBuffer: PByte;
  Source: Pointer;
  i: Integer;
begin
  // $03 means move next $03 bytes to output
  InputBuffer[0] := $03;
  for i := 1 to 3 do
    InputBuffer[i] := i;
  InputBuffer[4] := 0;
  Source := @InputBuffer;
  // 5 bytes input should result in 3 bytes output
  FDecoder.Decode(Source, FDecompressBuffer, 5, 3);
  // There should be 0 bytes available
  Check(FDecoder.CompressedBytesAvailable = 0, Format('Compressed bytes not 0 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 3 bytes decompressed
  Check(FDecoder.DecompressedBytes = 3, Format('Decompressed bytes not 3 but %d',
    [FDecoder.DecompressedBytes]));
  OutputBuffer := FDecompressBuffer;
  for i := 1 to 3 do begin
    Check(OutputBuffer^ = i,
      Format('Decompressed byte at index %d has unexpected value %x instead of %x',
      [i, OutputBuffer^, i]));
    Inc(OutputBuffer);
  end;
end;

procedure TCUTRLEDecoderTests.TestDecompress4Bytes03xxBuffer2;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
  i: Integer;
begin
  // $03 means move next $03 bytes to output
  InputBuffer[0] := $03;
  for i := 1 to 3 do
    InputBuffer[i] := i;
  Source := @InputBuffer;
  // 4 bytes input should result in 3 bytes output, but output buffer is only 2 bytes
  FDecoder.Decode(Source, FDecompressBuffer, 4, 2);
  // There should be 3 bytes available since we couldn't move the data bytes
  Check(FDecoder.CompressedBytesAvailable = 3, Format('Compressed bytes not 3 but %d',
    [FDecoder.CompressedBytesAvailable]));
  // There should be 0 bytes decompressed
  Check(FDecoder.DecompressedBytes = 0, Format('Decompressed bytes not 0 but %d',
    [FDecoder.DecompressedBytes]));
end;

// ********** TAmigaRGBDecoderTests **********

procedure TAmigaRGBDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder16 := TAmigaRGBDecoder.Create(16);
  FDecoder16.DecodeInit;
  FDecoder32 := TAmigaRGBDecoder.Create(32);
  FDecoder32.DecodeInit;
end;

procedure TAmigaRGBDecoderTests.TearDown;
begin
  FDecoder16.Free;
  FDecoder32.Free;
  inherited TearDown;
end;

procedure TAmigaRGBDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder16);
  TestCompressedSizeLimits(FDecoder32);
end;

procedure TAmigaRGBDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder16);
  TestDecompressedSizeLimits(FDecoder32);
end;

procedure TAmigaRGBDecoderTests.TestDecompressIncomplete16;
var
  Source: Pointer;
  InputBuffer: array [0..3] of byte;
begin
  Source := @InputBuffer;

  // Testing incomplete input.
  // 1 byte input
  InputBuffer[0] := $ff; // Should be at least a word.
  TestDecompress(FDecoder16, Source, 1, BUFSIZE, 1, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := $07; // Should be at least a word.
  TestDecompress(FDecoder16, Source, 1, 2, 1, 0, dsNotEnoughInput, 2);

  // 2 bytes input
  InputBuffer[0] := $ff; // first byte is data
  InputBuffer[1] := $00; // second byte runcount 0 means next byte is runlength
  TestDecompress(FDecoder16, Source, 2, 2, 0, 0, dsNotEnoughInput, 3);

  // 3 bytes input
  InputBuffer[2] :=  $00; // runlength 0 means next Word is runlength.
  TestDecompress(FDecoder16, Source, 3, 2, 0, 0, dsNotEnoughInput, 4);

  // 4 bytes input, that should be 5
  InputBuffer[3] :=  $00;
  TestDecompress(FDecoder16, Source, 4, 2, 1, 0, dsNotEnoughInput, 5);
end;

procedure TAmigaRGBDecoderTests.TestDecompressIncomplete32;
var
  Source: Pointer;
  InputBuffer: array [0..6] of byte;
begin
  Source := @InputBuffer;
  // Testing incomplete input.
  // 1 byte input
  InputBuffer[0] := $ff; // Should be at least a dword.
  TestDecompress(FDecoder32, Source, 1, BUFSIZE, 1, 0, dsNotEnoughInput, 1);
  InputBuffer[0] := $07; // Should be at least a dword.
  TestDecompress(FDecoder32, Source, 1, 4, 1, 0, dsNotEnoughInput, 2);

  // 2 bytes input, 4 needed
  InputBuffer[0] := $ff; // Should be at least a dword.
  InputBuffer[1] := $00;
  TestDecompress(FDecoder32, Source, 2, BUFSIZE, 2, 0, dsNotEnoughInput, 3);
  TestDecompress(FDecoder32, Source, 2, 4, 2, 0, dsNotEnoughInput, 4);

  // 3 bytes input, 4 needed
  InputBuffer[0] := $ff; // Should be at least a dword.
  InputBuffer[2] := $00;
  TestDecompress(FDecoder32, Source, 3, BUFSIZE, 3, 0, dsNotEnoughInput, 5);
  TestDecompress(FDecoder32, Source, 3, 4, 3, 0, dsNotEnoughInput, 6);

  // 4 bytes input
  InputBuffer[0] := $ff; // first byte is data
  InputBuffer[3] := $00; // 4th byte runcount 0 means next byte is runlength
  TestDecompress(FDecoder32, Source, 4, 4, 0, 0, dsNotEnoughInput, 7);

  // 5 bytes input
  InputBuffer[4] :=  $00; // runlength 0 means next Word is runlength.
  TestDecompress(FDecoder32, Source, 5, 4, 0, 0, dsNotEnoughInput, 8);

  // 6 bytes input, that should be 7
  InputBuffer[5] :=  $00;
  TestDecompress(FDecoder32, Source, 6, 4, 1, 0, dsNotEnoughInput, 9);
end;

procedure TAmigaRGBDecoderTests.TestDecompressFill16;
var
  Source: Pointer;
  InputBuffer: array [0..8] of byte;
  i: Integer;
begin
  Source := @InputBuffer[0];

  // 2 bytes input
  InputBuffer[0] := $ff; // first byte is data
  InputBuffer[1] := $01; // combined data and runcount 1: Fill data word in output 1 times
  TestDecompress(FDecoder16, Source, 2, 2, 0, 2, dsOk, 1);
  TestDecompress(FDecoder16, Source, 2, 1, 0, 0, dsOutputBufferTooSmall, 2);
  InputBuffer[1] := $07; // combined data and runcount 7 (highest value): Fill data word in output 7 times
  TestDecompress(FDecoder16, Source, 2, 14, 0, 14, dsOk, 3);
  TestDecompress(FDecoder16, Source, 2, 13, 0, 12, dsOutputBufferTooSmall, 4);

  // 3 bytes input
  InputBuffer[0] := $ff; // first byte is data
  InputBuffer[1] := $00; // combined data and runcount 0
  InputBuffer[2] := $01; // RunCount = 1: Fill data word 1 times in output
  TestDecompress(FDecoder16, Source, 3, 2, 0, 2, dsOk, 5);
  TestDecompress(FDecoder16, Source, 3, 1, 0, 0, dsOutputBufferTooSmall, 6);
  InputBuffer[2] := $ff; // RunCount = 255: Fill data word 255 times in output
  TestDecompress(FDecoder16, Source, 3, 2*255, 0, 2*255, dsOk, 7);
  TestDecompress(FDecoder16, Source, 3, 2*255-1, 0, 2*255-2, dsOutputBufferTooSmall, 8);

  // 5 bytes input
  InputBuffer[0] := $ff; // first byte is data
  InputBuffer[1] := $00; // combined data and runcount 0
  InputBuffer[2] := $00; // 0: next Word is RunCount
  InputBuffer[3] := $01; // Low word of count
  InputBuffer[4] := $00; // High word of count. Count = 1.
  TestDecompress(FDecoder16, Source, 5, 2, 0, 2, dsOk, 9);
  TestDecompress(FDecoder16, Source, 5, 1, 0, 0, dsOutputBufferTooSmall, 10);
  InputBuffer[3] := $80; // Low word of count
  InputBuffer[4] := $01; // Count = $0180 = 384
  TestDecompress(FDecoder16, Source, 5, 2*384, 0, 2*384, dsOk, 11);
  TestDecompress(FDecoder16, Source, 5, 2*384-1, 0, 2*384-2, dsOutputBufferTooSmall, 12);
  TestDecompress(FDecoder16, Source, 5, 2*384+1, 0, 2*384, dsNotEnoughInput, 13);

  // Test 0 RunCount
  // Since expected output of 0 will already cause decompressing to stop
  // we first decompress some other valid data.
  // This copies 1 word to output
  InputBuffer[0] := $ff; // first byte is data
  InputBuffer[1] := $01; // combined data and runcount 1: Fill data word in output 1 times
  // Now 5 bytes with in the end a 0 runcount
  InputBuffer[2] := $aa; // first byte is data
  InputBuffer[3] := $00; // combined data and runcount 0: next byte is RunCount
  InputBuffer[4] := $00; // 0 byte RunCount: next Word is RunCount
  InputBuffer[5] := $00; // Low word of count
  InputBuffer[6] := $00; // Count = 0
  // Result here ok since PackedSize > 0 isn't checked because this format doesn't
  // know the exact input size.
  TestDecompress(FDecoder16, Source, 7, 2, 5, 2, dsOk, 14);
  // Same but test with data after the 0 count.
  InputBuffer[7] := $bb; // first byte is data
  InputBuffer[8] := $01; // combined data and runcount 1: Fill data word in output 1 times
  TestDecompress(FDecoder16, Source, 9, 4, 0, 4, dsOk, 15);
end;

procedure TAmigaRGBDecoderTests.TestDecompressFill32;
var
  Source: Pointer;
  InputBuffer: array [0..14] of byte;
  i: Integer;
begin
  Source := @InputBuffer[0];

  // 4 bytes input
  InputBuffer[0] := $ff; // first byte is data
  InputBuffer[1] := $ee; // second byte is data
  InputBuffer[2] := $dd; // third byte is data
  InputBuffer[3] := $01; // combined data and runcount 1: Fill data dword in output 1 times
  TestDecompress(FDecoder32, Source, 4, 4, 0, 4, dsOk, 1);
  TestDecompress(FDecoder32, Source, 4, 3, 0, 0, dsOutputBufferTooSmall, 2);
  InputBuffer[3] := $7f; // combined data and runcount $7f = 127 (highest value): Fill data dword in output 127 times
  TestDecompress(FDecoder32, Source, 4, 127*4, 0, 127*4, dsOk, 3);
  TestDecompress(FDecoder32, Source, 4, 127*4-1, 0, 127*4-4, dsOutputBufferTooSmall, 4);

  // 5 bytes input
  InputBuffer[3] := $00; // RunCount 0: next byte = RunCount
  InputBuffer[4] := $01; // RunCount 1
  TestDecompress(FDecoder32, Source, 5, 4, 0, 4, dsOk, 5);
  TestDecompress(FDecoder32, Source, 5, 3, 0, 0, dsOutputBufferTooSmall, 6);
  InputBuffer[4] := $ff; // RunCount = 255: Fill data dword 255 times in output
  TestDecompress(FDecoder32, Source, 5, 4*255, 0, 4*255, dsOk, 7);
  TestDecompress(FDecoder32, Source, 5, 4*255-1, 0, 4*255-4, dsOutputBufferTooSmall, 8);

  // 7 bytes input
  InputBuffer[4] := $00; // RunCount 0: Next word is RunCount.
  InputBuffer[5] := $01; // Low word of RunCount.
  InputBuffer[6] := $00; // High word of RunCount. RunCount = 1.
  TestDecompress(FDecoder32, Source, 7, 4, 0, 4, dsOk, 9);
  TestDecompress(FDecoder32, Source, 7, 3, 0, 0, dsOutputBufferTooSmall, 10);
  InputBuffer[5] := $80; // Low word of count
  InputBuffer[6] := $00; // Count = $0080 = 128
  TestDecompress(FDecoder32, Source, 7, 4*128, 0, 4*128, dsOk, 11);
  TestDecompress(FDecoder32, Source, 7, 4*128-1, 0, 4*128-4, dsOutputBufferTooSmall, 12);

  // Test 0 RunCount
  // Since expected output of 0 will already cause decompressing to stop
  // we first decompress some other valid data.
  // This copies 1 word to output
  InputBuffer[0] := $ab; // first byte is data
  InputBuffer[1] := $cd; // second byte is data
  InputBuffer[2] := $ef; // third byte is data
  InputBuffer[3] := $01; // combined data and runcount 1: Fill data word in output 1 times
  // Now 5 bytes with in the end a 0 runcount
  InputBuffer[4] := $99; // data 1
  InputBuffer[5] := $88; // data 2
  InputBuffer[6] := $77; // data 3
  InputBuffer[7] := $00; // combined data and runcount 0: next byte is RunCount
  InputBuffer[8] := $00; // 0 byte RunCount: next Word is RunCount
  InputBuffer[9] := $00; // Low word of count
  InputBuffer[10] := $00; // Count = 0
  // Result here ok since PackedSize > 0 isn't checked because this format doesn't
  // know the exact input size.
  TestDecompress(FDecoder32, Source, 11, 4, 7, 4, dsOk, 13);
  // Same but test with data after the 0 count.
  InputBuffer[11] := $bb; // first byte is data
  InputBuffer[12] := $bb; // second byte is data
  InputBuffer[13] := $bb; // third byte is data
  InputBuffer[14] := $01; // combined data and runcount 1: Fill data word in output 1 times
  TestDecompress(FDecoder32, Source, 15, 8, 0, 8, dsOk, 14);
end;

// ********** TVDATRLEDecoderTests **********

procedure TVDATRLEDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder := TVDATRLEDecoder.Create;
end;

procedure TVDATRLEDecoderTests.TearDown;
begin
  FDecoder.Free;
  inherited TearDown;
end;

procedure TVDATRLEDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TVDATRLEDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

procedure TVDATRLEDecoderTests.TestDecompressCommands;
var
  Source: Pointer;
  InputBuffer: array [0..20] of byte;
begin
  Source := @InputBuffer;

  // Testing both incomplete and complete input.
  // Less than 6 bytes input should always result in invalid buffer size
  // At least 3 at the start and I think 2 at the end.
  TestDecompress(FDecoder, Source, 1, BUFSIZE, 0, 0, dsInvalidBufferSize, 1);
  TestDecompress(FDecoder, Source, 5, BUFSIZE, 0, 0, dsInvalidBufferSize, 2);

  // Test incomplete data after commands
  // First word - 2 is command count, big endian, in this case 1
  InputBuffer[0] := $00;
  InputBuffer[1] := $06; // CommandCount big endian = 4 (6-2)
  // Commands follow here, Data follows after CommandCount bytes
  InputBuffer[2] := $00; // First command (Move)
  InputBuffer[3] := $01; // Second command (Fill)
  InputBuffer[4] := $ff; // Third command (-1 = Move 1 word)
  InputBuffer[5] := $02; // Fourth command (2 = Fill 2 words)
  TestDecompress(FDecoder, Source, 6, BUFSIZE, 0, 0, dsInvalidBufferSize, 3);

  // Command 0 - Big endian RunLength word. Output count literal words from data words.
  InputBuffer[6] := $00;
  TestDecompress(FDecoder, Source, 7, 2, 1, 0, dsNotEnoughInput, 4);
  InputBuffer[7] := $01; // RunLength = 1 (= Wordcount needed for input and output)
  TestDecompress(FDecoder, Source, 8, 2, 0, 0, dsNotEnoughInput, 5);
  InputBuffer[8] := $01; // Data
  InputBuffer[9] := $02; // Data
  TestDecompress(FDecoder, Source, 10, 1, 2, 0, dsOutputBufferTooSmall, 6);
  TestDecompress(FDecoder, Source, 10, 2, 0, 2, dsOk, 7);
  TestDecompress(FDecoder, Source, 10, 4, 0, 2, dsNotEnoughInput , 8);

  // Command 1 - Big endian RunLength word. Output one word of data count times.
  InputBuffer[10] := $00;
  TestDecompress(FDecoder, Source, 11, 4, 1, 2, dsNotEnoughInput, 9);
  InputBuffer[11] := $01; // RunLength = 1 (= Wordcount needed for input and output)
  TestDecompress(FDecoder, Source, 12, 4, 0, 2, dsNotEnoughInput, 10);
  InputBuffer[12] := $01; // Data
  InputBuffer[13] := $02; // Data
  TestDecompress(FDecoder, Source, 14, 3, 2, 2, dsOutputBufferTooSmall, 11);
  TestDecompress(FDecoder, Source, 14, 4, 0, 4, dsOk, 12);
  TestDecompress(FDecoder, Source, 14, 6, 0, 4, dsNotEnoughInput , 13);

  // Command < 0. Output abs(Command) as count words from data words
  InputBuffer[14] := $00; // data
  TestDecompress(FDecoder, Source, 15, 6, 1, 4, dsNotEnoughInput, 14);
  InputBuffer[15] := $00; // data
  TestDecompress(FDecoder, Source, 16, 6, 0, 6, dsOk, 15);
  TestDecompress(FDecoder, Source, 16, 5, 2, 4, dsOutputBufferTooSmall, 16);
  TestDecompress(FDecoder, Source, 16, 8, 0, 6, dsNotEnoughInput , 17);

  // Command >= 2. Output Command as count. Read one data word and copy count times to output.
  // In this case count = 2 = minimum in this case
  InputBuffer[16] := $ff; // data
  TestDecompress(FDecoder, Source, 17, 10, 1, 6, dsNotEnoughInput, 18);
  InputBuffer[17] := $ee; // data
  // Outputting 2 words = 4 bytes
  TestDecompress(FDecoder, Source, 18, 10, 0, 10, dsOk, 19);
  TestDecompress(FDecoder, Source, 18, 9, 2, 6, dsOutputBufferTooSmall, 20);
  TestDecompress(FDecoder, Source, 18, 12, 0, 10, dsNotEnoughInput , 21);

  // Test CommandCount = 0
  TestDecompress(FDecoder, Source, 20, 12, 2, 10, dsNotEnoughInput, 22);
end;

// ********** TGIFLZWDecoderTests **********

// Only minimal tests here since it's a lot more difficult to manually
// prepare test data for this. Instead we use our collection of test images
// including fuzzed ones to check for problems in the decoder.

procedure TGIFLZWDecoderTests.SetUp;
begin
  inherited SetUp;
  // For now only test starting with a code size of 8.
  FDecoder := TGIFLZWDecoder.Create(8);
end;

procedure TGIFLZWDecoderTests.TearDown;
begin
  FDecoder.Free;
  inherited TearDown;
end;

procedure TGIFLZWDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TGIFLZWDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

// ********** TLZ77DecoderTests **********

// Since LZ77 already has its own error codes it is not using DecoderStatus.
// Only minimal tests here since it's a lot more difficult to manually
// prepare test data for this. Instead we use our collection of test images
// including fuzzed ones to check for problems in the decoder.
// We are also using zlib for this which is a well tested library.

procedure TLZ77DecoderTests.SetUp;
begin
  inherited SetUp;
  // For now only test starting with the parameters PSP uses.
  FDecoder := TLZ77Decoder.Create(Z_FINISH, False);
  FDecoder.DecodeInit;
end;

procedure TLZ77DecoderTests.TearDown;
begin
  FDecoder.DecodeEnd;
  FDecoder.Free;
  inherited TearDown;
end;

procedure TLZ77DecoderTests.TestCompressedSize0;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  InputBuffer[0] := 0;
  Source := @InputBuffer;
  // Test for zero length input buffer
  FDecoder.Decode(Source, FDecompressBuffer, 0, 100);
  Check(TLZ77Decoder(FDecoder).ZLibResult = Z_BUF_ERROR,
    Format('ZLib dcoding status not Z_BUF_ERROR but %d.',
    [TLZ77Decoder(FDecoder).ZLibResult]));
  Check(TLZ77Decoder(FDecoder).AvailableInput = 0, Format('Compressed bytes not 0 but %d',
    [TLZ77Decoder(FDecoder).AvailableInput]));
  // Test for negative length input buffer
  FDecoder.Decode(Source, FDecompressBuffer, -1, 100);
  Check(TLZ77Decoder(FDecoder).ZLibResult = Z_BUF_ERROR,
    Format('ZLib dcoding status not Z_BUF_ERROR but %d.',
    [TLZ77Decoder(FDecoder).ZLibResult]));
  Check(TLZ77Decoder(FDecoder).AvailableInput = -1, Format('Compressed bytes not -1 but %d',
    [TLZ77Decoder(FDecoder).AvailableInput]));
end;

procedure TLZ77DecoderTests.TestDecompressedSize0;
var InputBuffer: array [0..1] of byte;
  Source: Pointer;
begin
  InputBuffer[0] := 0;
  Source := @InputBuffer;
  // Test for zero length input buffer
  FDecoder.Decode(Source, FDecompressBuffer, 1, 0);
  Check(TLZ77Decoder(FDecoder).ZLibResult = Z_BUF_ERROR,
    Format('ZLib dcoding status not Z_BUF_ERROR but %d.',
    [TLZ77Decoder(FDecoder).ZLibResult]));
  Check(TLZ77Decoder(FDecoder).AvailableInput = 0, Format('Compressed bytes not 0 but %d',
    [TLZ77Decoder(FDecoder).AvailableInput]));
  Check(TLZ77Decoder(FDecoder).AvailableOutput = 0, Format('Decompressed bytes not 0 but %d',
    [TLZ77Decoder(FDecoder).AvailableOutput]));
  // Test for negative length input buffer
  FDecoder.Decode(Source, FDecompressBuffer, 1, -1);
  Check(TLZ77Decoder(FDecoder).ZLibResult = Z_BUF_ERROR,
    Format('ZLib dcoding status not Z_BUF_ERROR but %d.',
    [TLZ77Decoder(FDecoder).ZLibResult]));
  Check(TLZ77Decoder(FDecoder).AvailableInput = 1, Format('Compressed bytes not 1 but %d',
    [TLZ77Decoder(FDecoder).AvailableInput]));
  Check(TLZ77Decoder(FDecoder).AvailableOutput = 0, Format('Decompressed bytes not 0 but %d',
    [TLZ77Decoder(FDecoder).AvailableOutput]));
end;

// ********** TXcfRLEDecoderTests **********

procedure TXcfRLEDecoderTests.SetUp;
begin
  inherited SetUp;
  FDecoder1 := TXcfRLEDecoder.Create(1);
  // RGBA
  FDecoder4 := TXcfRLEDecoder.Create(4);
end;

procedure TXcfRLEDecoderTests.TearDown;
begin
  FDecoder1.Free;
  // TODO:
  FDecoder4.Free;
  inherited TearDown;
end;

procedure TXcfRLEDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder1);
end;

procedure TXcfRLEDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder1);
end;

procedure TXcfRLEDecoderTests.TestDecompressIncomplete1;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  // Tests for Decoding of 1 bytes per pixel Decoder incomplete data.
  // Packed Data is loaded per plane.

  // 1 byte input
  InputBuffer[0] := $80; // -128 --> next big endian word = RunLength
  TestDecompress(FDecoder1, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 1);
  TestDecompress(FDecoder1, Source, 1, 1, 0, 0, dsNotEnoughInput, 2);
  InputBuffer[0] := $ff; // -1 = move RunLength (1) bytes input to output
  TestDecompress(FDecoder1, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 3);
  TestDecompress(FDecoder1, Source, 1, 1, 0, 0, dsNotEnoughInput, 4);
  InputBuffer[0] := $7f; // 127 = next big endian word = RunLength
  TestDecompress(FDecoder1, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 5);
  TestDecompress(FDecoder1, Source, 1, 1, 0, 0, dsNotEnoughInput, 6);
  InputBuffer[0] := $0; // 0 = fill 1 byte input RunLength (1) times to output
  TestDecompress(FDecoder1, Source, 1, BUFSIZE, 0, 0, dsNotEnoughInput, 7);
  TestDecompress(FDecoder1, Source, 1, 1, 0, 0, dsNotEnoughInput, 8);

  // 2 bytes input
  InputBuffer[0] := $80; // -128 --> next big endian word = RunLength
  InputBuffer[1] := $ff; // Incomplete RunLength Word
  TestDecompress(FDecoder1, Source, 2, BUFSIZE, 1, 0, dsNotEnoughInput, 9);
  TestDecompress(FDecoder1, Source, 2, 1, 1, 0, dsNotEnoughInput, 10);
  InputBuffer[0] := $fe; // -2 = move RunLength (2) bytes input to output
  InputBuffer[1] := $ff; // Data byte (but we need 2 data bytes)
  TestDecompress(FDecoder1, Source, 2, BUFSIZE, 0, 1, dsNotEnoughInput, 11);
  TestDecompress(FDecoder1, Source, 2, 2, 0, 1, dsNotEnoughInput, 12);
  InputBuffer[0] := $7f; // 127 = next big endian word = RunLength
  InputBuffer[1] := $ff; // Incomplete RunLength Word
  TestDecompress(FDecoder1, Source, 2, BUFSIZE, 1, 0, dsNotEnoughInput, 13);
  TestDecompress(FDecoder1, Source, 2, 1, 1, 0, dsNotEnoughInput, 14);

  // more bytes of input
  InputBuffer[0] := $80; // -128 --> next big endian word = RunLength
  InputBuffer[1] := $01;
  InputBuffer[2] := $00; // RunLength 256, but no data bytes follow
  TestDecompress(FDecoder1, Source, 3, BUFSIZE, 0, 0, dsNotEnoughInput, 15);
  TestDecompress(FDecoder1, Source, 3, 256, 0, 0, dsNotEnoughInput, 16);
  InputBuffer[1] := $00;
  InputBuffer[2] := $02; // RunLength 2, but only 1 data byte follows
  InputBuffer[3] := $ff; // First and only data byte
  TestDecompress(FDecoder1, Source, 4, BUFSIZE, 0, 1, dsNotEnoughInput, 17);
  TestDecompress(FDecoder1, Source, 4, 2, 0, 1, dsNotEnoughInput, 18);
  InputBuffer[0] := $7f; // 127 = next big endian word = RunLength
  InputBuffer[1] := $00;
  InputBuffer[2] := $02; // RunLength = 2 but no data byte follows
  TestDecompress(FDecoder1, Source, 3, BUFSIZE, 0, 0, dsNotEnoughInput, 19);
  TestDecompress(FDecoder1, Source, 3, 1, 0, 0, dsNotEnoughInput, 20);
end;

procedure TXcfRLEDecoderTests.TestDecompressMove1;
var InputBuffer: array [0..4] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := $80; // -128 --> next big endian word = RunLength
  InputBuffer[1] := $00;
  InputBuffer[2] := $01; // RunLength 1. Move 1 data byte to output
  InputBuffer[3] := $ab; // data byte
  TestDecompress(FDecoder1, Source, 4, BUFSIZE, 0, 1, dsNotEnoughInput, 1);
  TestDecompress(FDecoder1, Source, 4, 1, 0, 1, dsOk, 2);
  InputBuffer[2] := $02; // RunLength 2. Move 2 data bytes to output
  InputBuffer[3] := $ab; // data byte
  InputBuffer[4] := $cd; // data byte
  TestDecompress(FDecoder1, Source, 5, BUFSIZE, 0, 2, dsNotEnoughInput, 3);
  TestDecompress(FDecoder1, Source, 5, 2, 0, 2, dsOk, 4);
  TestDecompress(FDecoder1, Source, 5, 1, 1, 1, dsOutputBufferTooSmall, 5);

  InputBuffer[0] := $ff; // RunLength 1. Move 1 data byte to output
  InputBuffer[1] := $ab; // data byte
  TestDecompress(FDecoder1, Source, 2, BUFSIZE, 0, 1, dsNotEnoughInput, 6);
  TestDecompress(FDecoder1, Source, 2, 1, 0, 1, dsOk, 7);
  InputBuffer[0] := $fe; // RunLength 2. Move 2 data bytes to output
  InputBuffer[1] := $ab; // data byte
  InputBuffer[2] := $ba; // data byte
  TestDecompress(FDecoder1, Source, 3, BUFSIZE, 0, 2, dsNotEnoughInput, 8);
  TestDecompress(FDecoder1, Source, 3, 2, 0, 2, dsOk, 9);
  TestDecompress(FDecoder1, Source, 3, 1, 1, 1, dsOutputBufferTooSmall, 10);
end;

procedure TXcfRLEDecoderTests.TestDecompressFill1;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer;
  InputBuffer[0] := $7f; // 128 --> next big endian word = RunLength
  InputBuffer[1] := $00;
  InputBuffer[2] := $01; // RunLength 1. Fill data byte 1 times to output
  InputBuffer[3] := $ab; // data byte
  TestDecompress(FDecoder1, Source, 4, BUFSIZE, 0, 1, dsNotEnoughInput, 1);
  TestDecompress(FDecoder1, Source, 4, 1, 0, 1, dsOk, 2);
  InputBuffer[2] := $02; // RunLength 2. Fil data byte 2 times to output
  InputBuffer[3] := $ba; // data byte
  TestDecompress(FDecoder1, Source, 4, BUFSIZE, 0, 2, dsNotEnoughInput, 3);
  TestDecompress(FDecoder1, Source, 4, 2, 0, 2, dsOk, 4);
  TestDecompress(FDecoder1, Source, 4, 1, 0, 1, dsOutputBufferTooSmall, 5);

  InputBuffer[0] := $00; // RunLength 1. Fill data byte 1 times to output
  InputBuffer[1] := $ab; // data byte
  TestDecompress(FDecoder1, Source, 2, BUFSIZE, 0, 1, dsNotEnoughInput, 6);
  TestDecompress(FDecoder1, Source, 2, 1, 0, 1, dsOk, 7);
  InputBuffer[0] := $01; // RunLength 2. Fill data byte 2 times to output
  InputBuffer[1] := $ba; // data byte
  TestDecompress(FDecoder1, Source, 2, BUFSIZE, 0, 2, dsNotEnoughInput, 8);
  TestDecompress(FDecoder1, Source, 2, 2, 0, 2, dsOk, 9);
  TestDecompress(FDecoder1, Source, 2, 1, 0, 1, dsOutputBufferTooSmall, 10);
end;

// ********** TXcfNoCompressionDecoderTests **********

procedure TXcfNoCompressionDecoderTests.SetUp;
begin
  inherited SetUp;
  // For now only test starting with 4 bytes per pixel (RGBA)
  FDecoder := TXcfNoCompressionDecoder.Create(4);
end;

procedure TXcfNoCompressionDecoderTests.TearDown;
begin
  FDecoder.Free;
  inherited TearDown;
end;

procedure TXcfNoCompressionDecoderTests.TestCompressedSize0;
begin
  TestCompressedSizeLimits(FDecoder);
end;

procedure TXcfNoCompressionDecoderTests.TestDecompressedSize0;
begin
  TestDecompressedSizeLimits(FDecoder);
end;

procedure TXcfNoCompressionDecoderTests.TestDecompressedMove;
var InputBuffer: array [0..3] of byte;
  Source: Pointer;
begin
  Source := @InputBuffer; // Actual data doesn't matter here
  // Remember UnpackedSize is in pixels but DecompressedBytes is bytes.
  TestDecompress(FDecoder, Source, 4, BUFSIZE, 0, 4, dsNotEnoughInput, 1);
  TestDecompress(FDecoder, Source, 4, 1, 0, 4, dsOk, 2);
end;


initialization
  RegisterTests('Test GraphicEx.Unit GraphicCompression',
    [
      TTGARLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TPackbitsDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TPSPRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TPCXRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TSGIRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TRLADecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TCutRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TAmigaRGBDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TVDATRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TGIFLZWDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TLZ77DecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TXcfRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TXcfNoCompressionDecoderTests{$IFNDEF FPC}.Suite{$ENDIF}
    ]);
end.
