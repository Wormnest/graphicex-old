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
  GraphicCompression
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


implementation


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

// ********** TCutRLEDecoderTests **********

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

initialization
  RegisterTests('Test GraphicEx.Unit GraphicCompression',
    [
      TTGARLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TPSPRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF},
      TCutRLEDecoderTests{$IFNDEF FPC}.Suite{$ENDIF}
    ]);
end.
