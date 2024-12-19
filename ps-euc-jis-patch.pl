#! /usr/bin/perl
#
#   ps-euc-jis-patch.pl --
#	tgif-2.16j-p12 ���Ǥ��� PS�ե�����������ơ�
#	�Ƕ��PostScript�ץ�󥿤ǽ����Ǥ���褦�ˤ���
#	���ܸ�ʸ����ϡ���ꥵ��ե���Ȥ������ʿ���ե���Ȥ�Ȥ�
#
#   �ѹ�����:
#	0.1: Aug. 4, 1998 by Dai ISHIJIMA
#
#   �Ȥ�����:
#	ps-euc-jis-patch.pl < foo.ps > baa.ps
#
#   ����:
#	�Ǥ� tgif-2.16j-p12�������
#	CID�ѥå� (CIDfont-patch for tgif-216pl12jp v1.1) ��
#	�����äƤ��� tgif ���б����Ƥ��ޤ���
#
#   ư���ǧ:
#	ghostscript-2.6.2 + 261j ������ʿ���ե���ȥ��ݡ��Ȼ�
#	    (PostScript�С������ 54.0)
#	Apple LaserWriter 16/600PS-J
#	    (PostScript�С������ 2014.106)
#	Xerox LaserWind 1040PS + ���ץ����ե����J2
#	    (PostScript�С������ 2014.107)
#	Xerox LaserPress 2100PS
#	    (PostScript�С������ 2016.108)
#

while (<>) {
    if (/^(.* \()([^\(]*\\[0-9].*)(\) .*show.*$)/) { # ���ܸ�ʸ���󤢤�
	print "% !", $1, " | ", $2, " | ", $3, "\n";
	#
	# \[0-3][0-7][0-7] ������ʸ�����ƥ���ֿʹֲ��ɷ����פˤ���
	#
	$len = length($2);
	$showstring = "";
	for ($i = 0; $i < $len; $i++) {
	    $ch = substr($2, $i, 1);
	    if (($ch eq "\\") && (substr($2, $i + 1, 1) =~ "[0-3]")) {
		$oct = 0;
		for ($j = 0; $j < 3; $j++) {
		    ++$i;
		    $oct = $oct * 8 + ord(substr($2, $i, 1)) - ord('0');
		}
		$showstring = $showstring . sprintf("%c", $oct);
	    }
	    else {
		$showstring = $showstring . $ch;
	    }
	}
	print "% !", $1, $showstring, $3, "\n";
	#
	# asciiʸ�����EUCʸ����δ֤˥��������ץ����ɤ���������
	#
	$escape = "";
	$mode = "ASCII";
	$len = length($showstring);
	for ($i = 0; $i < $len; $i++) {
	    $ch = substr($showstring, $i, 1);
	    if ((ord($ch) >= 128) && ($mode eq "ASCII")) {
		$escape = $escape . "\\377\\001";
		$mode = "JAPANESE";
	    }
	    elsif ((ord($ch) < 128) && ($mode ne "ASCII")) {
		$escape = $escape . "\\377\\000";
		$mode = "ASCII";
	    }
	    # 8�ӥå��ܤ򥪥դˤ��ơ�JIS���󥳡��ǥ��󥰤ˤ���
	    $escape = $escape . sprintf("%c", ord($ch) & 0x7f);
	}
	print $1, $escape, $3, "\n";
    }
    else {
	print ;
    }
#
#   PS�ե��������Ƭ���񤭴���
#
    if (/^tgifdict begin/) {
	print <<"EOF"



%%Title: shiftmappedfont.ps
%
% <newfont> <asciifont> <kanjifont> SHIFTMAPPEDeucfont
/SHIFTMAPPEDeucfont {
    dup
    /GothicBBB-Medium-EUC-H eq {
	pop
	/HeiseiKakuGo-W5-H
    } if
    dup
    /GothicBBB-Medium-EUC-V eq {
	pop
	/HeiseiKakuGo-W5-V
    } if
    dup
    /Ryumin-Light-EUC-H eq {
	pop
	/HeiseiMin-W3-H
    } if
    dup
    /Ryumin-Light-EUC-V eq {
	pop
	/HeiseiMin-W3-V
    } if
    20 dict begin
	/FontType 0 def
	/WMode 0 def
	/FMapType 3 def
	/FontMatrix matrix def
	/Encoding [1 0] def
	/FontBBox {0 0 0 0} def
	/FDepVector [ 4 2 roll
	    findfont 1 scalefont
	    exch
	    findfont 1 scalefont
	] def
	/FontName exch def
	FontName currentdict
    end
    definefont pop
} def
EOF
#
    }
    if (/^\/eucfont {/) {
	print "    SHIFTMAPPEDeucfont\n} def\n\n/UNUSEDeucfont {\n";
    }
}

# �����ޤ�
