      /If Defined(Header_Copied)
      /EOF
      /Else
      /Define Header_Copied

     HOption(*SrcStmt:*NoDebugIO)

      /If Defined(*CRTBNDRPG)
     HDftActGrp(*NO) ActGrp('QILE')
      /Endif

      /If Defined(*CrtRpgMod)
     HNoMain
      /Endif

      /Endif

