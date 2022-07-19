require 'discordrb'
require 'discordrb/webhooks'
require 'yaml'
require 'base64'
require './codings.rb'
include Space0
include WrongLay
config = YAML.load_file("config.yml")

def isLang? var
	return var == 'ru' || var == 'eng' || var == 'рус' || var == 'англ'
end

def isQuote? var
	return var == '\'' || var == '"' || var == '`'
end

bot =	Discordrb::Commands::CommandBot.new(
	token: config["Token"],
	client_id: config["ID"],
	prefix: config["prefix"]
)

bot.command :help do |event|
	commands = """
`Префикс`: `#{config['prefix'] != '' ? config['prefix'] : 'нету'}`
`help`: список комманд
`coin`: попробуйте угадать орёл или решка?
`cringe`: определяет насколько кринжовое то что вы написали
`choose`: выбирает что лучше в процентах из 2х вещей
`info`: информация о боте
`ban`: забанить упомянутого участника
`clear`: Очищает от 2 до 9999 сообщений в канале
`kick`: выгнать упомянутого участника
`profile`: информация о вас
`rand`: рандомное число диапазон которого можно настроить
`randstr`: рандомная строка язык и длинну которой можно указать
`base64_decode`: расшифровывает base64 кодировку
`base64_encode`: преобразовывает ваше сообщение в base64
`space0_decode`: расшифровывает space 0 кодировку
`space0_encode`: преобразовывает ваше сообщение в space 0
`wronglay_decode`: расшифровывает неправильную раскладку
`wronglay_encode`: преобразовывает ваше сообщение в неправильнуюю раскладку
"""
	event.channel.send_embed do |embed|
		embed.title = "Команды"
		embed.description = commands
		embed.colour = config["color"]
	end
end

bot.command :ping do |event|
	event.channel.send_embed do |embed|
		embed.description = "pong"
		embed.colour = config["color"]
	end
end

bot.command :info do |event|
	event.channel.send_embed do |embed|
		embed.title = "Hjass v0.1"
		embed.description =  "Это тестовый бот сделанный чисто по приколу\nЯзык программирования: Ruby\nСделал: Eldyj#9888"
		embed.colour = config["color"]
	end
end

bot.command :choose do |event, *args|
	args = args.length == 4 ? ["#{args[0]} #{args[1]}", "#{args[2]} #{args[3]}"] : args
	event.channel.send_embed do |embed|
		wha1 = rand 0 .. 100
		embed.description = "#{args[0]} - #{wha1}%\n#{args[1]} - #{100 - wha1}%"
		embed.colour = config["color"]
	end
end

bot.command :cringe do |event, *args|
	event.channel.send_embed do |embed|
		who = args.join(' ').downcase == "я" ? "Ты" : args.join(' ').downcase == "ты" ? "Я" : args.join(' ')
		cringe = args.join(' ').downcase == "ты" ? "0" : rand(0 ... 101)
		embed.description = "#{who} на #{cringe}% кринж"
		embed.colour = config["color"]
	end
end

bot.command :coin, max_args:1 do |event, args|
	coin = rand 0 .. 1
	variants = YAML.load_file './coins.yml'
	variant = rand 0 ... variants.length
	if  coin == 1 && args != nil
		win = args.downcase == 'орёл' || args.downcase == 'орел' ? variants[variant][0] : variants[variant][2]
	elsif args != nil
		win = args.downcase == 'решка' ? variants[variant][1] : variants[variant][3]
	else
		win = coin == 1 ? variants[variant][4] : variants[variant][5]
	end
	event.channel.send_embed do |embed|
		embed.title = "Монета"
		embed.description = win
		embed.colour = config["color"]
	end
end

bot.command :space0_decode do |event, *args|
	event.channel.send_embed do |embed|
		embed.title = "Space 0"
		embed.description = Space0::decodes0 args.join ' '
		embed.colour = config["color"]
	end
end

bot.command :space0_encode do |event, *args|
	event.channel.send_embed do |embed|
		embed.title = "Space 0"
		embed.description = Space0::encodes0 args.join ' '
		embed.colour = config["color"]
	end
end

bot.command :wronglay_decode do |event, *args|
	event.channel.send_embed do |embed|
		embed.title = "Неправильная раскладка"
		embed.description = WrongLay::decodewl args.join ' '
		embed.colour = config["color"]
	end
end

bot.command :wronglay_encode do |event, *args|
	event.channel.send_embed do |embed|
		embed.title = "Неправильная раскладка"
		embed.description = WrongLay::encodewl args.join ' '
		embed.colour = config["color"]
	end
end

bot.command :base64_decode do |event, *args|
	event.channel.send_embed do |embed|
		embed.title = "Base64"
		embed.description = Base64.decode64 args.join ' '
		embed.colour = config["color"]
	end
end

bot.command :base64_encode do |event, *args|
	event.channel.send_embed do |embed|
		embed.title = "Base64"
		embed.description = Base64.encode64 args.join ' '
		embed.colour = config["color"]
	end
end

bot.command :rand, min_args:0, max_args:2 do |event, startnum, lastnum|
	if startnum == nil
		resault = rand 1 ... 100
	elsif lastnum == nil
		resault = rand 1 ... startnum.to_i
	else
		resault = rand startnum.to_i ... lastnum.to_i
	end
	event.channel.send_embed do |embed|
		embed.title = "Рандомное число"
		embed.description = resault
		embed.colour = config["color"]
	end
end

bot.command :randstr, min_args:0,max_args:2 do |event, lang, length|
	if lang == nil
		lang = 'all'
		length = rand 2 ... 40
	elsif isLang?(lang) && length == nil
		length = rand 2 ... 40
	elsif length == nil
		length = lang
		lang = 'all'
	elsif isLang?(length)
		lang , length = length, lang
	end
	abc = lang == 'ru' || lang == 'рус' ? Space0::RuAbc : lang == 'eng' || lang == 'англ' ? Space0::EngAbc : lang == 'all' ? Space0::Abc : 'amogus is sus'
	if length.to_i <= 40
		if length.to_i >= 2
			resault = ''
			for i in 0 ... length.to_i do
				resault += abc[rand 0 ... abc.length - 1]
			end
		else
			resault = 'ОШИБКА: слишком маленькое чиcло!'
		end
	else
		resault = 'ОШИБКА: слишком большое число!'
	end
	event.channel.send_embed do |embed|
		embed.title = "Рандомная строка"
		embed.description = resault
		embed.colour = config["color"]
	end
end

bot.command :profile do |event|
	boosttime = event.user.boosting_since == nil ? 'никогда' : boosttime = event.user.boosting_since
	event.channel.send_embed do |embed|
		embed.title = "#{event.user.distinct}"
		embed.description = """
идентификатор: **#{event.user.id}**
присоеденился: **#{event.user.joined_at}**
последний буст: **#{boosttime}**
		"""
		embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: event.user.avatar_url
		embed.colour = config["color"]
	end
end

bot.command :kick, min_args:1, max_args:1 do |event, args|
  member = event.bot.parse_mention args
  if event.author.permission? :kick_members #|| event.user.id == 802199418345357353
    begin
			event.server.kick member
		rescue Discordrb::Errors::NoPermission
			resault = "У меня нет прав на кик #{args}!"
		else
			resault = "#{member.distinct} изгнан"
    end
	elsif !event.author.permission? :kick_members
		resault = 'У вас нет прав на изгнание пользователей'
	end
	event.channel.send_embed do |embed|
		embed.title = "Кик"
		embed.description = resault
		embed.colour = config["color"]
	end
end

bot.command :ban ,min_args:1, max_args:1 do |event, args|
  member = event.bot.parse_mention(args)
  if event.author.permission? :ban_members #|| event.user.id == 802199418345357353
    begin
			event.server.ban member
		rescue Discordrb::Errors::NoPermission
			resault = 'У меня нет прав чтобы забанить этого пользвователя!'
		else
			resault = "#{args} Забанен"      
    end
	elsif !event.author.permission? :kick_members
    resault = 'У вас нет прав что-бы отправить этого пользователя в баню'
  end
	event.channel.send_embed do |embed|
		embed.title = "Бан"
		embed.description = resault
		embed.colour = config["color"]
	end
end

bot.command :clear do |event, args|
  howmatch = args.to_i
	if event.author.permission? :manage_messages #|| event.user.id == 802199418345357353
    begin
			if howmatch <= 99
				event.channel.prune howmatch
			elsif howmatch >= 100 && howmatch <= 9999
				if howmatch>=1000
					slep = [1.0/4.0, 1.0/2.0]
				else
					slep = [1.0/100.0, 1.0/100.0]
				end
				while howmatch >= 100
					sleep(slep[0])
					event.channel.prune 100
					howmatch -= 100
					sleep(slep[1])
				end
				if howmatch > 0
					event.channel.prune howmatch
				end
			end
		rescue Discordrb::Errors::NoPermission
			resault = 'У меня нет прав чтобы очистить этот канал'
		else
			if howmatch > 9999
				resault = 'Слишком много сообщений для удаления!'
			else
				disclaimer = args.to_i > 100 ? '(возможно медленно потомучто сообщение удалялись с шагом 100)' : ''
				resault = "Канал успешно очищен, **#{args}** сообений удалено\n#{disclaimer}"
			end
    end
  end
	event.channel.send_embed do |embed|
		embed.title = "Очистка"
		embed.description = resault
		embed.colour = config["color"]
	end
end

at_exit { bot.stop }
bot.run