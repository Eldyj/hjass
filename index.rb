require  'discordrb'                  # main library
require  'discordrb/webhooks'         # for webhooks
require  'yaml'                       # for configs
require  'base64'                     # for base64 decode & encode
require  './codings.rb'               # more custom codings
include  Space0                       # a1z26 like coding
include  WrongLay                     # decode wrong keyboard layour
config = YAML.load_file "config.yml"  # bot config, for color name version, etc

def is_lang? var
	return var == 'ru' || var == 'eng' || var == 'рус' || var == 'англ'
end

bot =	Discordrb::Commands::CommandBot.new(
	token:     config['token'],
	client_id: config['id'],
	prefix:    config['prefix']
)

bot.command :help do |event|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Команды"
		embed.description = """
			*---Информация*
			`help`: список комманд
			`changelog`: изменения в обновлении
			`github`: ссылка на исходный код
			`info`: немного о боте
			*---Приколы*
			`choose`: выбирает что лучше в процентах из 2х вещей
			`coin`: бот подбросит монету
			`cringe`: определяет степень кринжа
			`server`: информация о сервере
			`profile`: ваш профиль в сообщении
			`rand`: рандомное число
			`randstr`: рандомная строка
			*---Модерирование*
			`kick`: выгоняет пользователя
			`ban`: банит пользователя
			`clear`: чистит сообщения от 2 до 9999
			*---Кодировки*
			`base64_decode`: расшифровывает base64 кодировку
			`base64_encode`: зашифровывает сообщение в base64
			`space0_decode`: расшифровывает space 0 кодировку
			`space0_encode`: зашифровывает сообщение в space 0
			`wronglay_decode`: расшифровывает неправильную раскладку
			`wronglay_encode`: зашифровывае сообщение в англ. раскладку
		"""
		embed.colour = config['color']
	end
end

bot.command :changelog do |event, version|
	version = version == nil ? config['version'] : version.to_f <= config['version'] ? version.to_f : config['version']
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "#{config['name']} v#{version} changelog"
		embed.description =  YAML.load_file('changelog.yml')[version]
		embed.colour = config['color']
	end
end

bot.command :github do |event|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = 'GitHub'
		embed.description = "#{config['name']} - это бот с открытым исходным кодом, посмотреть его можно на [GitHub](https://github.com/Eldyj/hjass)"
		embed.colour = config['color']
	end
end

bot.command :info do |event|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "#{config['name']} v#{config['version']}"
		embed.description = """
			Присутствую на #{bot.servers.length} серверах
			Мой [discord](https://discord.gg/T6uazz8Shj) сервер
			Сделал: Eldyj#9888
			Язык программирования: Ruby
		"""
		embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: bot.avatar_url
		embed.colour = config['color']
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
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Монета"
		embed.description = win
		embed.colour = config['color']
	end
end

bot.command :choose do |event, *args|
	wha1 = rand 0 .. 100
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.description = """
		#{args[0]} - #{wha1}%
		#{args[1]} - #{100 - wha1}%
		"""
		embed.colour = config['color']
	end
end

bot.command :cringe do |event, *args|
	args = args.join ' ' 
	args = args.downcase
	who = args == "я" ? "Ты" : args == "ты" ? "Я" : args
	cringe = args == "ты" ? "0" : rand(0 ... 101)
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.description = "#{who} на #{cringe}% кринж"
		embed.colour = config['color']
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
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Рандомное число"
		embed.description = resault
		embed.colour = config['color']
	end
end

bot.command :randstr, min_args:0,max_args:2 do |event, lang, length|
	if lang == nil
		lang, length = 'all', rand(2 ... 40)
	elsif is_lang?(lang) && length == nil
		length = rand 2 ... 40
	elsif length == nil
		length, lang = lang, 'all'
	elsif is_lang?(length)
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
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Рандомная строка"
		embed.description = resault
		embed.colour = config['color']
	end
end

bot.command :server do |event|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "#{event.server.name}"
		embed.description = """
			владелец: **#{event.server.owner.distinct}**
			id сервера: **#{event.server.id}**
			кол-во ролей: **#{event.server.roles.length}**
			кол-во участников: **#{event.server.member_count}**
			кол-во каналов: **#{event.server.channels.length}**
			кол-во эмодзи: **#{event.server.emoji.length}**
			уровень буста: **#{event.server.boost_level}**
		"""
		embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: event.server.icon_url
		embed.colour = config['color']
	end
end

bot.command :avatar do |event, member|
	member = member != nil ? event.bot.parse_mention(member).on(event.server) : event.user
	event.channel.send_embed do |embed|
		embed.image = Discordrb::Webhooks::EmbedImage.new url: member.avatar_url
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: member.distinct, icon_url: event.user.avatar_url
	end
end

bot.command :profile do |event, member|
	member = member != nil ? event.bot.parse_mention(member).on(event.server) : event.user
	boost_time = member.boosting_since == nil ? 'Никогда' : member.boosting_since
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "#{member.username}"
		embed.description = """
			идентификатор: **#{member.id}**
			высшая роль: **#{member.highest_role.name}**
			последний буст: **#{boost_time}**
			присоеденился: **#{member.joined_at.to_s[0 ... 18]}**
			присоеденился в дискорд: **#{member.creation_time.to_s[0 ... 18]}**
		"""
		embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: member.avatar_url
		embed.colour = config['color']
	end
end

bot.command :ban ,min_args:1, max_args:1 do |event, args|
  member = event.bot.parse_mention(args)
  if event.author.permission? :ban_members
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
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Бан"
		embed.description = resault
		embed.colour = config['color']
	end
end

bot.command :clear do |event, args|
  howmatch = args.to_i
	if event.author.permission? :manage_messages
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
				disclaimer = args.to_i > 100 ? '(возможно медленно потому-что сообщение удалялись с шагом 100)' : ''
				resault = "Канал успешно очищен, **#{args}** сообений удалено\n#{disclaimer}"
			end
    end
  end
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Очистка"
		embed.description = resault
		embed.colour = config['color']
	end
end

bot.command :kick, min_args:1, max_args:1 do |event, args|
  member = event.bot.parse_mention args
  if event.author.permission? :kick_members
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
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Кик"
		embed.description = resault
		embed.colour = config['color']
	end
end

bot.command :space0_decode do |event, *args|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Space 0"
		embed.description = Space0::decode_s0 args.join ' '
		embed.colour = config['color']
	end
end

bot.command :space0_encode do |event, *args|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Space 0"
		embed.description = Space0::encode_s0 args.join ' '
		embed.colour = config['color']
	end
end

bot.command :wronglay_decode do |event, *args|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Неправильная раскладка"
		embed.description = WrongLay::decode_wl args.join ' '
		embed.colour = config['color']
	end
end

bot.command :wronglay_encode do |event, *args|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Неправильная раскладка"
		embed.description = WrongLay::encode_wl args.join ' '
		embed.colour = config['color']
	end
end

bot.command :base64_decode do |event, *args|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Base64"
		embed.description = Base64.decode64 args.join ' '
		embed.colour = config['color']
	end
end

bot.command :base64_encode do |event, *args|
	event.channel.send_embed do |embed|
		embed.author = Discordrb::Webhooks::EmbedAuthor.new name: event.user.distinct , icon_url: event.user.avatar_url
		embed.title = "Base64"
		embed.description = Base64.encode64 args.join ' '
		embed.colour = config['color']
	end
end

at_exit { bot.stop }
bot.run