#===================================================================
#        UnitData.tsv(アイテム情報)取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package UnitData;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{AssemblyNum}         = {};
    $self->{AssemblyNum}{0}      = {};
    $self->{AssemblyNum}{1}      = {};
    $self->{Datas}{Item}         = StoreData->new();
    $self->{Datas}{AssemblyNum}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "i_no",
                "name",
                "kind",
                "unique_1",
                "unique_2",
                "ap",
                "spending_en",
                "value",
                "ammunition_cost",
                "weight",
                "turning_speed",
                "guard_elemental",
                "guard_value",
                "precision",
                "punding",
                "aerosol",
                "bullet",
                "loading",
                "weapon_element",
                "add_abnormity",
                "strength",
                "gunshot",
                "struggle",
                "reaction",
                "control",
                "preparation",
                "fitly",
                "equip",
                "fuka_1",
                "fuka_2",
                "orig_name",
                "drunkenness",
    ];

    $self->{Datas}{Item}->Init($header_list);
    
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "division_type",
                "proper_name_id",
                "num",
    ];
    $self->{Datas}{AssemblyNum}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Item}->SetOutputName       ( "./output/chara/item_"         . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{AssemblyNum}->SetOutputName( "./output/chara/assembly_num_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜ファイル名
#-----------------------------------#
sub GetData{
    my $self         = shift;
    my $file_name    = shift;
    
    my $content   = &IO::FileRead ( $file_name );
    my @file_data = split(/\n/, $content);
    shift(@file_data); # ヘッダ行削除

    $self->{LastENo} = 0;
    
    foreach my  $data_set(@file_data) {
        my $data = [];
        @$data   = split(ConstData::SPLIT, $data_set);
        
        if (scalar(@$data) < 1 || !$$data[0] || !$$data[2]) {next;}
        
        $self->GetUnitData($data);
    } 
    
    return;
}

#-----------------------------------#
#    アイテムデータ取得
#------------------------------------
#    引数｜tsvデータ一行を分割した配列
#-----------------------------------#
sub GetUnitData{
    my $self         = shift;
    my $data         = shift;
    my $e_no = int($$data[0] / 31);

    if ($self->{LastENo} > $e_no) {return;} # データの隙間にちょこちょこ挟まる重複データ、結果HTML上には存在しないデータは無視する
    $self->{LastENo} = $e_no;

    my $i_no = $$data[0] % 31;

    my $name = $$data[1];
    my $kind = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[2]);
    my $unique_1 = $$data[3];
    my $unique_2 = $$data[4];
    my $ap = $$data[5];
    my $spending_en = $$data[6];
    my $value = $$data[7];
    my $ammunition_cost = $$data[8];
    my $weight = $$data[9];
    my $turning_speed = $$data[10];
    
    my $guard_elemental = $$data[11];
    if ($guard_elemental =~ /^[0-9]+$/) {
        # カタログデータと違って防御値が数字で入っているので、変換する
        $guard_elemental =~ s/1/物理/s; 
        $guard_elemental =~ s/2/粒子/s;
        $guard_elemental =~ s/3/霊障/s;
        $guard_elemental =~ s/4/電子/s;
        $guard_elemental =~ s/5/火炎/s;
    }
    $guard_elemental = $self->{CommonDatas}{ProperName}->GetOrAddId($guard_elemental);

    my $guard_value = $$data[12];
    my $precision = $$data[13];
    my $punding = $$data[14];
    my $aerosol = $$data[15];
    my $bullet = $$data[16];
    my $loading = $$data[17];
    my $weapon_element = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[18]);
    my $add_abnormity = $$data[19];
    my $strength = $$data[21];
    my $gunshot = $$data[22];
    my $struggle = $$data[23];
    my $reaction = $$data[24];
    my $control = $$data[25];
    my $preparation = $$data[26];
    my $fitly = $$data[27];
    my $equip = $$data[29];
    my $fuka_1 = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[30]);
    my $fuka_2 = $self->{CommonDatas}{ProperName}->GetOrAddId($$data[31]);

    my $orig_name = $$data[36];
    $orig_name =~ s/\s//g;
    $orig_name = $self->{CommonDatas}{ProperName}->GetOrAddId($orig_name);

    my $drunkenness = $$data[37] ? $$data[37] : 0;

    my @datas=($self->{ResultNo}, $self->{GenerateNo}, $e_no, $i_no, $name, $kind, $unique_1, $unique_2, $ap, $spending_en, $value, $ammunition_cost, $weight, $turning_speed, $guard_elemental, $guard_value, $precision, $punding, $aerosol, $bullet, $loading, $weapon_element, $add_abnormity, $strength, $gunshot, $struggle, $reaction, $control, $preparation, $fitly, $equip, $fuka_1, $fuka_2, $orig_name, $drunkenness);
    $self->{Datas}{Item}->AddData(join(ConstData::SPLIT, @datas));
    
    if ($equip) {
        $self->{AssemblyNum}{$e_no}{0}{$kind}      += 1;
        $self->{AssemblyNum}{$e_no}{1}{$orig_name} += 1;
    }

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;

    # アセンブル数情報の書き出し
    foreach my $e_no (sort{$a <=> $b} keys %{ $self->{AssemblyNum} } ) {
        foreach my $division_type (sort{$a <=> $b} keys %{ $self->{AssemblyNum}{$e_no} } ) {
            foreach my $proper_name_id (sort{$a <=> $b} keys %{ $self->{AssemblyNum}{$e_no}{$division_type} } ) {
                $self->{Datas}{AssemblyNum}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $e_no, $division_type, $proper_name_id, $self->{AssemblyNum}{$e_no}{$division_type}{$proper_name_id} )));
            }
        }
    }

    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
