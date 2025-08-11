# Fix 'grub-mkimage: error: relocation 0x2b is not implemented yet'
self: super: {
  grub2 = super.grub2.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (super.fetchpatch {
        url = "https://file.savannah.gnu.org/file/0263-Use-medany-instead-of-large-model-for-RISCV.patch?file_id=56184";
        sha256 = "sha256-s6uPdM6vug+7lZ1FPhup+P4uFRO02+YtbVxDUDn1WLc=";
      })
    ];
  });
}
