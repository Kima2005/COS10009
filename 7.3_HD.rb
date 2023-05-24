require 'rubygems'
require 'gosu'
require './album_functions(HD).rb'

WIN_WIDTH = 1450
WIN_HEIGHT = 700

# download images from: https://drive.google.com/drive/folders/1cNkVP4bsae7pUkgMThPKzNCPCmGEejGV?usp=sharing
# after download, put in folder name: images

# download album_images from: https://drive.google.com/drive/folders/1NF0CqO-Z_Pd9BzatYlh_ouw4OWLHNDf4?usp=sharing
# after download, put in folder name: album_images

#download music from: https://drive.google.com/drive/folders/1WDAU1ttZYsBQ_fIgA5CXQqCrkYpwRuvs?usp=sharing
# after download, put in folder name: music(HD)

TEXT_COLOR = Gosu::Color::BLACK
PLAYING_TEXT_COLOR = Gosu::Color::YELLOW
DEFAULT_TEXT_COLOR = Gosu::Color::GRAY

module ZOrder
    BACKGROUND, MIDDLE, TOP = *0..2
end

# draw media buttons
def draw_buttons()
    @previous_button.draw(587.5-37.5, 600, ZOrder::TOP)
    @next_button.draw(700, 600, ZOrder::TOP)
    @stop_button.draw(812.5-37.5, 600, ZOrder::TOP)

    if Gosu::Song.current_song == nil || Gosu::Song.current_song.playing? == false         
        @play_button.draw(662.5-37.5, 600, ZOrder::TOP)
    else
        @pause_button.draw(662.5-37.5, 600, ZOrder::TOP)
    end

    if @mode_index == 1
        @arrow_button.draw(887.5-37.5, 600, ZOrder::TOP)
    elsif @mode_index == 2
        @shuffle_button.draw(887.5-37.5, 600, ZOrder::TOP)
    elsif @mode_index == 3
        @loop_button.draw(887.5-37.5, 600, ZOrder::TOP)    
    end
end   
 
# draw volume
def draw_volume()
    vol_height = @volume * 110        
    @volume_image.draw(1050, 605, ZOrder::TOP)
    Gosu.draw_rect(1120, 612, 113, 3, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    Gosu.draw_rect(1120, 635, 113, 3, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    Gosu.draw_rect(1117, 612, 3, 26, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    Gosu.draw_rect(1230, 615, 3, 20, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    Gosu.draw_rect(1120, 615, vol_height, 20, Gosu::Color::WHITE, ZOrder::MIDDLE, mode=:default)
end

# draw the image of each page including album images and album  titles
def draw_albums_page(display_index)
    @music_image.draw(450,300, ZOrder::TOP)
    i = 0 
    @albums_title_text = []
    while i < @albums.length
        @albums_title_text << Gosu::Image.from_text(@albums[i].title.to_s.upcase,18,{:bold => true, :width => 250, :align => :center})
        i += 1
   
    end
    i = 0
    while i < 4      
        if display_index >= 8
            display_index = 8
            @album_image[display_index].draw(@text_image_x[0], 0, ZOrder::TOP)
            if @playing_album_title == @albums[display_index].title && @favourite_mode != true
                @album_text_color = PLAYING_TEXT_COLOR
            else
                @album_text_color = DEFAULT_TEXT_COLOR  
            end    
            @albums_title_text[display_index].draw(@text_image_x[0], 270, ZOrder:: TOP,1,1, @album_text_color)
            i += 1
        else
            @album_image[display_index].draw(@text_image_x[i], 0, ZOrder::TOP)
            if @playing_album_title == @albums[display_index].title && @favourite_mode != true
                @album_text_color = PLAYING_TEXT_COLOR
            else
                @album_text_color = DEFAULT_TEXT_COLOR  
            end    
            @albums_title_text[display_index].draw(@text_image_x[i], 270, ZOrder:: TOP,1,1, @album_text_color)
            display_index += 1
            i += 1
        end
    end
end
  
# print list song name of the album selected
def print_selected_album()
    i = 0
    playing_tracks = []
    while i < @albums[@selected_album_id].tracks.length
        playing_track = Gosu::Image.from_text("#{i + 1}  #{@albums[@selected_album_id].tracks[i].name}", 18,{:width => 250, :align => :left})
        playing_tracks << playing_track
        i += 1
    end
    album_title = Gosu::Image.from_text(@albums[@selected_album_id].title.to_s, 20,{:bold => true, :width => 300, :align => :left})
    album_artist = Gosu::Image.from_text(@albums[@selected_album_id].artist.to_s, 16,{:width => 300, :align => :left})
    album_title.draw(750, 300, ZOrder::TOP, 1, 1, TEXT_COLOR)
    album_artist.draw(750, 330, ZOrder::TOP, 1, 1, TEXT_COLOR)
    i = 0
    while i <  @albums[@selected_album_id].tracks.length     
        if @albums[@selected_album_id].tracks[i].name == @playing_song_title 
            @track_text_color = PLAYING_TEXT_COLOR    
            @display_favourite_index = i
            a = check_if_favourite_song()
            if a == 0
                @heart_on.draw(1030, @text_track_y[i], ZOrder::TOP)      
            elsif a == -1
                @heart_off.draw(1030, @text_track_y[i], ZOrder::MIDDLE)  
            end   
            a = -1
        else
            @track_text_color = DEFAULT_TEXT_COLOR      
        end
        playing_tracks[i].draw(750, @text_track_y[i], ZOrder::TOP, 1, 1, @track_text_color)
        i += 1     
    end
    
end

# draw the hover media buttons
def draw_hover_buttons()
    if mouse_over_previous_button(mouse_x, mouse_y)
        Gosu.draw_rect(587.5-37.5, 600, 50, 50, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    end
    if mouse_over_pause_or_play_button(mouse_x, mouse_y)
        Gosu.draw_rect(662.5-37.5, 600, 50, 50, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    end
    if mouse_over_next_button(mouse_x, mouse_y)
        Gosu.draw_rect(737.5-37.5, 600, 50, 50, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    end
    if mouse_over_stop_button(mouse_x, mouse_y)    
        Gosu.draw_rect(812.5-37.5, 600, 50, 50, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    end
    if mouse_over_play_mode_button(mouse_x, mouse_y)
        Gosu.draw_rect(887.5-37.5, 600, 50, 50, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
    end
    if mouse_over_favourite_list(mouse_x, mouse_y) && @favourite_song_location.length != 0
        Gosu.draw_rect(150-3, 500-3, 96, 25+6, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
    end
    if mouse_over_rewind_button( mouse_x, mouse_y)
        Gosu.draw_rect(15, 185, 70, 70, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
    elsif mouse_over_forward_button( mouse_x, mouse_y)
        Gosu.draw_rect(WIN_WIDTH-85, 185, 70, 70, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
    end
end
# draw the hover album images
def draw_hover_albums()
    
    if @display_album_index <= 4
        if ((mouse_x > 150 and mouse_x < 400) and (mouse_y > 0 and mouse_y < 250))
            Gosu.draw_rect(145, 0, 260, 255, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
        elsif ((mouse_x > 450 and mouse_x < 700) and (mouse_y > 0 and mouse_y < 250))
            Gosu.draw_rect(445, 0, 260, 255, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
        elsif ((mouse_x > 750 and mouse_x < 1000) and (mouse_y > 0 and mouse_y < 250))
            Gosu.draw_rect(745, 0, 260, 255, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
        elsif ((mouse_x > 1050 and mouse_x < 1300) and (mouse_y > 0 and mouse_y < 250))
            Gosu.draw_rect(1045, 0, 260, 255, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
        end 
    elsif @display_album_index > 4 
        if ((mouse_x > 150 and mouse_x < 400) and (mouse_y > 0 and mouse_y < 250))
            Gosu.draw_rect(145, 0, 260, 255, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
        end
    end
  
end

# read the album image locations of file named "Music(HD).txt"
def read_album_image_location()
    @album_image = []
    i = 0 
    while i < @albums.length       
        @album_image <<  Gosu::Image.new(@albums[i].image.chomp)
        i += 1
    end
end

# draw the favourite list after selecting favourite song
def draw_favourite_list()
    if  @favourite_song_location.length != 0
        @favourite_list = Gosu::Image.from_text("Favourite List", 25, {:bold => true, :width => 200, :align => :left})
        @favourite_list.draw(150, 300, ZOrder::TOP, 1,1, TEXT_COLOR)
        @play_list = Gosu::Image.from_text("Play List", 25, {:bold => true, :width => 100, :align => :left})
        @play_list.draw(150, 500, ZOrder::TOP, 1,1, TEXT_COLOR)
    end
    i = 0 
    while i < 7
        if @favourite_album_song_title[i] != nil
            @list_track = Gosu::Image.from_text("#{i + 1}  #{@favourite_album_song_title[i].to_s}", 18,{:width => 250, :align => :left})
            if @playing_favourite_song_title  == @favourite_album_song_title[i] && @favourite_mode == true
                @favourite_text_color = PLAYING_TEXT_COLOR
            else
                @favourite_text_color = DEFAULT_TEXT_COLOR
            end
            @list_track.draw(150, @text_track_y[i], ZOrder::TOP, 1, 1, @favourite_text_color)
            
        end
        i+=1
    end

end


class PLAY < Gosu::Window
    def initialize
        super(WIN_WIDTH, WIN_HEIGHT)
        self.caption = "Song"
        music_file = File.new("Music(HD).txt", "r")
		@albums = read_in_album(music_file)       
        @track_id = 0
        @display_album_index = 0
        @mode_index = 1
        read_album_image_location()
        @text_image_x = [150, 450, 750, 1050]
        @text_track_y = [350, 370, 390, 410, 430, 450, 470]
        @volume_image = Gosu::Image.new("images/volume.png")
        @previous_button = Gosu::Image.new("images/previous.png")
        @pause_button = Gosu::Image.new("images/pause.png")
        @stop_button = Gosu::Image.new("images/stop.png")
        @next_button = Gosu::Image.new("images/next.png") 
        @play_button = Gosu::Image.new("images/play.png") 
        @arrow_button = Gosu::Image.new("images/arrow.png")
        @loop_button = Gosu::Image.new("images/loop.png")
        @shuffle_button = Gosu::Image.new("images/shuffle.png")
        @background_color = Gosu::Color::AQUA
        @background_color2 = Gosu::Color.argb(100,120,150,250)
        @music_image = Gosu::Image.new("images/music.png")
        @rewind_button = Gosu::Image.new("images/rewind_button.png")
        @forward_button = Gosu::Image.new("images/forward_button.png")
        @heart_on = Gosu::Image.new("images/heart_on.png")
        @heart_off = Gosu::Image.new("images/heart_off.png")
        @track_title_clicked = false
        @first_select_album = false
        @volume = 0.6
        @favourite_song_location = []
        @favourite_album_song_title = []
        @favourite_mode = false
        @favourite_song_id = 0
        @mode_heart = false       
    end


    def needs_cursor?
        true
    end

    
   

    def draw()
        draw_volume()
        Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT-150, @background_color, ZOrder::BACKGROUND, mode=:default)
        Gosu.draw_rect(0, WIN_HEIGHT-150, WIN_WIDTH, 150, @background_color2, ZOrder::BACKGROUND, mode=:default)
        draw_albums_page(@display_album_index)  
        draw_buttons() 
        draw_hover_buttons()
        draw_hover_albums()
        draw_favourite_list()
        @rewind_button.draw(10, 180, ZOrder::TOP)
        @forward_button.draw(WIN_WIDTH-90, 180, ZOrder::TOP) 

        if @selected_album_id != nil && @favourite_mode == false
            print_selected_album()
        end
        
    end


    def track_title_clicked(mouse_x, mouse_y)
        if @selected_album_id != nil
            i = 0
            while i < @albums[@selected_album_id].tracks.length
                if ((mouse_x > 750 and mouse_x < 1000) and (mouse_y > @text_track_y[i]  and mouse_y < @text_track_y[i]+18))
                    return i
                end
                i += 1
            end
        end
    end


    def album_clicked()
        
        if @display_album_index == 0   
            if mouse_over_album_1(mouse_x, mouse_y)
                @favourite_mode = false
                @first_select_album = false
                @selected_album_id = 0      
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end           
                end    
            elsif mouse_over_album_2(mouse_x, mouse_y)
                  
                @favourite_mode = false
                @selected_album_id = 1              
                @first_select_album = false
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end         
                end                               
            elsif mouse_over_album_3(mouse_x, mouse_y)
                @favourite_mode = false
                  
                @selected_album_id = 2             
                @first_select_album = false   
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end       
                end                
            elsif mouse_over_album_4(mouse_x, mouse_y)
                @favourite_mode = false
                  
                @selected_album_id = 3              
                @first_select_album = false
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end         
                end   
            end   
        elsif  @display_album_index == 4
            if mouse_over_album_1(mouse_x, mouse_y)
                @favourite_mode = false
                  
                @first_select_album = false
                @selected_album_id = 4      
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end                     
                end    
            elsif mouse_over_album_2(mouse_x, mouse_y)
                @first_select_album = false
                @favourite_mode = false
                  
                @selected_album_id = 5              
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end       
                end                               
            elsif mouse_over_album_3(mouse_x, mouse_y)
                @first_select_album = false
                  
                @favourite_mode = false
                @selected_album_id = 6                
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end          
                end                
            elsif mouse_over_album_4(mouse_x, mouse_y)
                @first_select_album = false
                  
                @selected_album_id = 7         
                @favourite_mode = false     
                if Gosu::Song.current_song != nil
                    if @mode_index == 1
                        @track_id = 0
                        play_selected_album()   
                    elsif @mode_index == 2
                        @track_id = -1
                        play_selected_album()  
                    elsif @mode_index == 3
                        @track_id = 0
                        play_selected_album()   
                    end       
                end   
            end 
            elsif @display_album_index > 4  
                if mouse_over_album_1(mouse_x, mouse_y)
                    @first_select_album = false               
                    @selected_album_id = 8     
                    @favourite_mode = false
                    if Gosu::Song.current_song != nil
                        if @mode_index == 1
                            @track_id = 0
                            play_selected_album()   
                        elsif @mode_index == 2
                            @track_id = -1
                            play_selected_album()  
                        elsif @mode_index == 3
                            @track_id = 0
                            play_selected_album()   
                        end                    
                    end    
                end
        end                
        return @selected_album_id    
        
    end


    def buttons_clicked()
        if mouse_over_pause_or_play_button(mouse_x, mouse_y)
            if Gosu::Song.current_song == nil || Gosu::Song.current_song.paused? == true  
                if @selected_album_id != nil && @favourite_mode != true
                    @playing_song.play()
                    @playing_song.volume = @volume  
                elsif @favourite_mode == true                   
                    @playing_favourite_song.play()
                    @playing_song.volume = @volume 
                else
                    false    
                end
            else
                if @selected_album_id != nil && @favourite_mode != true
                    @playing_song.pause()
                    @playing_song.volume = @volume  
                elsif @favourite_mode == true
                    @playing_favourite_song.pause()
                else
                    false
                end
            end               
        end
        if mouse_over_previous_button(mouse_x, mouse_y)
            if @selected_album_id != nil && @favourite_mode != true
                play_previous_song()
            elsif @favourite_mode == true
                @favourite_song_id -= 2
                play_favourite_list() 

            else
                false
            end
        end
        if mouse_over_next_button(mouse_x, mouse_y)
            if @selected_album_id != nil && @favourite_mode != true
                play_next_song()
            elsif @favourite_mode == true                
                play_favourite_list() 
            else
                false
            end
        end
        if mouse_over_stop_button(mouse_x, mouse_y)
            if @selected_album_id != nil&& @favourite_mode != true
                play_back()
            elsif @favourite_mode == true  
                @favourite_song_id = 0
                play_favourite_list() 

            else
                false
            end
        end
        if @favourite_mode == false
            if track_title_clicked(mouse_x, mouse_y)                
                @track_id = track_title_clicked(mouse_x, mouse_y)
                @track_title_clicked = true
                play_selected_album()
            end
        end

    end


    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        end
        case id   
        when Gosu::MsLeft
            album_clicked()
            buttons_clicked()
            if @selected_album_id != nil || @favourite_mode == true
                if mouse_over_volume_control( mouse_x, mouse_y)                           
                    @volume = ((mouse_x - 1120)/110)                  
                    @playing_song = Gosu::Song.current_song 
                    @playing_song.play()
                    @playing_song.volume = @volume   
                end
            end

            if @favourite_song_location.length != 0 && @favourite_mode != true
                if mouse_over_favourite_list(mouse_x, mouse_y)
                    @favourite_mode = true
                    play_favourite_list()
                    @first_select_album = true 
                end
            end

            if @selected_album_id != nil && @display_favourite_index != nil
                a = check_if_favourite_song()
                if mouse_over_heart(mouse_x, mouse_y) && a == -1                      
                    i = @display_favourite_index
                    a = check_if_favourite_song()
                    if a == -1
                        if (@favourite_album_song_title.length < 7) && (@favourite_song_location.length < 7) 
                        @favourite_album_song_title << @playing_song_title
                        @favourite_song_location << @playing_song_location
                        end

                    elsif a == 0
                        false
                    end
                elsif mouse_over_heart(mouse_x, mouse_y) && @favourite_album_song_title != nil
                    @favourite_album_song_title.delete(@playing_song_title)
                    @favourite_song_location.delete(@playing_song_location)
                end
            else
                false
            end  

            if mouse_over_play_mode_button(mouse_x, mouse_y)
                if @selected_album_id != nil && @favourite_mode != true
                    if @mode_index == 1
                        @mode_index = 2
                    elsif @mode_index == 2
                        @mode_index = 3
                    elsif @mode_index == 3
                        @mode_index = 1    
                    end
                else
                    false
                end    
            end

            if mouse_over_rewind_button( mouse_x, mouse_y)
                if @display_album_index == 0 
                    @display_album_index -= 0
                    @playing_song = @playing_song
                else
                    @display_album_index -= 4
                    @playing_song = @playing_song
                end
            end
            if mouse_over_forward_button( mouse_x, mouse_y)
                if @display_album_index == (@albums.length - 1)
                     @display_album_index += 0
                     @playing_song = @playing_song
                else 
                    @display_album_index += 4
                    @playing_song = @playing_song
                end
            end            
        end
    end

    # convert to shuffle mode
    def shuffle_mode()
        current_track = @track_id - 1
        @track_id = rand(@albums[@selected_album_id].tracks.length)
        if @track_id == current_track
            shuffle_mode()
        end
        return @track_id
    end

    # play the favourite list
    def play_favourite_list()      
        if @favourite_song_id >= @favourite_album_song_title.length
            @favourite_song_id = 0
        end  
        if @first_select_album == false 
            @favourite_song_id = 0
        end
        if @favourite_song_id < 0
            @favourite_song_id = 0
        end

        @favourite_song_id += 1       
        @playing_favourite_song_title = @favourite_album_song_title[@favourite_song_id-1]
        @playing_favourite_song_location = @favourite_song_location[@favourite_song_id-1]  
        @playing_favourite_song = Gosu::Song.new(@playing_favourite_song_location)     
        @playing_favourite_song.play()        
        @playing_favourite_song.volume = @volume  
        
        
    end

    # play the album selected
    def play_selected_album()        
        if @mode_index == 2 && @track_id == -1 
            @track_id = 0
            @first_select_album = true
        elsif @mode_index == 2  && @track_title_clicked == false
            shuffle_mode()
        end       
        if @mode_index == 3 && @track_title_clicked == true
            @track_id -= 0
        elsif @mode_index == 3 && @track_id > 0
            @track_id -= 1
        end
      
        
        @track_title_clicked = false
        @track_id += 1  
        @playing_album_title = @albums[@selected_album_id].title
        @playing_song_title = @albums[@selected_album_id].tracks[@track_id-1].name  
        @playing_song_location = @albums[@selected_album_id].tracks[@track_id-1].location.chomp        
        @playing_song = Gosu::Song.new(@playing_song_location)  
        @playing_song.play()
        @playing_song.volume = @volume         
    end

    # play the next song in the album
    def play_next_song()
        if @track_id == 0
            @track_id += 1
        end
        if @track_id >= (@albums[@selected_album_id].tracks.length)   
            @track_id = 0
        end        
        @playing_song_title = @albums[@selected_album_id].tracks[@track_id].name 
        @track_id += 1
        @playing_song_location = @albums[@selected_album_id].tracks[@track_id-1].location.chomp
        @playing_song = Gosu::Song.new(@playing_song_location)
        @playing_song.play()
        @playing_song.volume = @volume  

    end

    # play the previous song in the album
    def play_previous_song()

        if @track_id > 1
            @track_id -= 1
            @playing_song_title = @albums[@selected_album_id].tracks[@track_id-1].name 
            @playing_song_location = @albums[@selected_album_id].tracks[@track_id-1].location.chomp
            @playing_song = Gosu::Song.new(@playing_song_location)
            @playing_song.play()     
            @playing_song.volume = @volume    
        elsif @track_id <= 1
            @track_id = @albums[@selected_album_id].tracks.length
            @playing_song_title = @albums[@selected_album_id].tracks[@track_id-1].name 
            @playing_song_location= @albums[@selected_album_id].tracks[@track_id-1].location.chomp
            @playing_song = Gosu::Song.new(@playing_song_location)
            @playing_song.play()  
            @playing_song.volume = @volume  
        end
        
    end
   
    # play the first song in the album
    def play_back()
    
        @track_id = 0
        @playing_song_title = @albums[@selected_album_id].tracks[@track_id].name 
        @playing_song_location = @albums[@selected_album_id].tracks[@track_id].location.chomp
        @playing_song = Gosu::Song.new(@playing_song_location)
        @playing_song.play()
        @playing_song.volume = @volume  
        @track_id += 1
        
    end

    def update()      
         
        if Gosu::Song.current_song == nil && @selected_album_id != nil && @favourite_mode != true
            if @track_id >= (@albums[@selected_album_id].tracks.length) && @mode_index != 3 && @mode_index != 2
                play_back()
            else                   
                play_selected_album()    
            end  
        elsif  Gosu::Song.current_song == nil && @favourite_mode == true
            play_favourite_list()
        end
    end

end

b = PLAY.new
b.show