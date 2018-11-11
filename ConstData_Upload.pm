#===================================================================
#        定数設定
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================

# パッケージの定義    ---------------#    
package ConstData;

# パッケージの使用宣言    ---------------#
use strict;
use warnings;

# 定数宣言    ---------------#
    use constant SPLIT        => "\t";    # 区切り文字

# ▼ 実行制御 =============================================
#      実行する場合は 1 ，実行しない場合は 0 ．
    
    use constant EXE_DATA       => 1;
        use constant EXE_DATA_PROPER_NAME => 1;
    use constant EXE_CHARA      => 1;
        use constant EXE_CHARA_NAME               => 1;
        use constant EXE_CHARA_ITEM               => 1;
        use constant EXE_CHARA_STATUS             => 1;
        use constant EXE_CHARA_SPEC               => 1;
        use constant EXE_CHARA_CONDITION_ALL_TEXT => 1;
        use constant EXE_CHARA_REWARD             => 1;
        use constant EXE_CHARA_BATTLE_SYSTEM      => 1;
        use constant EXE_CHARA_INTENTION          => 1;
        use constant EXE_CHARA_CONSORT_PLANE      => 1;
        use constant EXE_CHARA_ASSEMBLY_NUM       => 1;
    use constant EXE_CHARALIST  => 1;
        use constant EXE_CHARALIST_NEXT_BATTLE    => 1;
    use constant EXE_BATTLE     => 1;
        use constant EXE_BATTLE_BLOCK             => 1;
        use constant EXE_BATTLE_TRANSITION        => 1;
    use constant EXE_MARKET     => 1;

1;
