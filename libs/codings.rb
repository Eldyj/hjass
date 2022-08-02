module Space0
	StartAbc = ' 0123456789'
	EngAbc = 'abcdefghijklmnopqrstuvwxyzéèàëêù'
	RuAbc = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'
	SpecialAbc = '~!@#$%^&*()-=_+[]{}|\'\";:/?.>,<№'
	Abc = StartAbc + EngAbc + RuAbc + SpecialAbc
	def is_num? char
		return char == '0' || char == '1' || char == '2' || char == '3' || char == '4' || char == '5' || char == '6' || char == '7' || char == '8' || char == '9'
	end

	def encode_char_s0 char
		resault = ''
		for i in 0 ... Abc.length
			resault = char == Abc[i] ? i : resault
		end
		return "#{resault} "
	end

	def decode_char_s0 num
		return Abc[num]
	end

	def decode_s0 str
		i=0
		str = str.strip.split ''
		resault = ''
		for i in 0 ... str.length
			char = str[i]
			digitmain = is_num?(char)
			digit2nd = is_num?(str[i+1])
			digit3nd = is_num?(str[i+2])
			if digitmain && digit2nd && digit3nd
				char += str[i+1]
				char += str[i+2]
				str[i+1] = ''
				str[i+2] = ''
			elsif digitmain && digit2nd
				char += str[i+1]
				str[i+1] = ''
			end
			if digitmain
				resault += decode_char_s0(char.to_i)
			end
		end
		return resault
	end

	def encode_s0 str
		resault = ''
		str = str.downcase.strip.split ''
		for i in 0 ... str.length
			char = str[i]
			resault += encode_char_s0(char)
		end
		return resault
	end
end

module WrongLay
	AbcEngWL = ' 1234567890QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?qwertyuiop[]asdfghjkl;\'zxcvbnm,./'
	AbcRuWL = ' 1234567890ЙЦУКЕНГШЩЗХЪ/ФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,йцукенгшщзхъфывапролджэячсмитьбю.'
	def decode_char_wl char
		resault = ''
		for i in 0 ... AbcEngWL.length
			resault = char == AbcEngWL[i] ? AbcRuWL[i] : resault
		end
		return resault
	end
	def encode_char_wl char
		resault = ''
		for i in 0 ... AbcRuWL.length
			resault = char == AbcRuWL[i] ? AbcEngWL[i] : resault
		end
		return resault
	end
	def encode_wl str
		resault = ''
		for i in 0 ... str.length
			resault += encode_char_wl(str[i])
		end
		return resault
	end
	def decode_wl str
		resault = ''
		for i in 0 ... str.length
			resault += decode_char_wl(str[i])
		end
		return resault
	end
end