# -*- mode: python -*-
#
# pyinstaller -y --clean k40_whisperer.spec
# python -OO -m PyInstaller -y --clean k40_whisperer.spec
#

block_cipher = None

a = Analysis(['k40_whisperer.py'],
             pathex=['/Users/houser/Projects/K40_Whisperer'],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='k40_whisperer',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          runtime_tmpdir=None,
          console=False
		)
app = BUNDLE(exe,
            name='K40 Whisperer.app',
            icon='emblem.icns',
            bundle_identifier=None,
			info_plist={
				'NSPrincipleClass': 'NSApplication',
				'NSAppleScriptEnabled': False,
				'CFBundleIdentifier': 'com.scorchworks.k40_whisperer',
				'CFBundleName': 'K40 Whisperer',
				'CFBundleDisplayName': 'K40 Whisperer',
				'CFBundleShortVersionString': '0.57'
				}
			)
