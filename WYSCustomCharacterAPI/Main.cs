using GmmlPatcher;
using GmmlHooker;
using UndertaleModLib;
using UndertaleModLib.Models;
using System.Linq;
using System;
using WysApi.Api;
using System.IO;
using TSIMPH;
using Newtonsoft.Json;
using UndertaleModLib.Decompiler;
using System.Reflection;
using System.Globalization;

namespace WYSCustomCharacterAPI
{
    
    public class CustomCharacter
    {
        public string id = "placeholder";
        public string parentCharacter = "shelly";
        public bool overrideOnly = false;
        public string name = "placeholder";
        public string description = "placeholder";
        public string trailColor = "c_white";
        public string flareColor = "c_white";
        public string deathColor = "c_white";
        public string mainColor = "c_white";
        public bool allowSnailLines = true;
        public bool useSnailVoice = true;
        public bool useSlitherSound = true;
        public bool renderEyes = true;
        public double speedMultiplier = 1;
        public double underwaterFriction = 0.95;
        public double jumpMultiplier = 1;
        public double gravityMultiplier = 1;
        public double bubbleScale = 1;
        public int jumps = 2;
        public double conveyorMultiplier = 1;
        [JsonIgnore]
        public Dictionary<string, string> Scripts = new Dictionary<string, string>();
    }
    
    
    public class GameMakerMod : IGameMakerMod
    {

        public static Dictionary<string, string> GMLkvp = new Dictionary<string, string>();

        public static GlobalDecompileContext? GDC;

        public static List<CustomCharacter> CustomCharacters = new List<CustomCharacter>();

        public static List<string> DisabledIDs = new List<string>();

        public static string DefaultCharacterID = "shelly";

        public static Dictionary<string, string> DictionarizeGMLFolder(string gmlfolder)
        {
            Dictionary<string, string> Dict = new Dictionary<string, string>();
            
            try
            {
                string[] infos = Directory.GetFiles(gmlfolder);

                for (int i = 0; i < infos.Length; i++)
                {
                    FileInfo fo = new FileInfo(infos[i]);
                    //fo.Name
                    if (fo.Extension == ".gml")
                    {
                        Console.WriteLine("Reading File: " + fo.Name);
                        Dict.Add(Path.GetFileNameWithoutExtension(fo.Name), File.ReadAllText(infos[i]));
                        Patcher.AddFileToCache(0, infos[i]);
                    }
                }
            }
            catch
            {
                Logger.Log("Failed to read/open: " + gmlfolder, Logger.LogLevel.Error);
                Logger.Log("Expect strange behavior or future crashes!", Logger.LogLevel.Error);
                Console.ResetColor();
                return new Dictionary<string, string>();
            }

            return Dict;
        }

        public static bool LoadGMLFolder(string gmlfolder)
        {
            Logger.Log("Trying to add:" + gmlfolder);
            Dictionary<string, string> dict = DictionarizeGMLFolder(gmlfolder);
            foreach (KeyValuePair<string, string> kvp in dict)
            {
                GMLkvp.Add(kvp.Key, kvp.Value);
            }
            return dict.Count != 0;
        }

        private static List<CustomCharacter> LoadCharacters(string characterfolder)
        {
            List<CustomCharacter> chars = new List<CustomCharacter>();
            foreach (string path in Directory.GetDirectories(characterfolder))
            {
                Logger.Log("Adding:" + path);
                if (File.Exists(Path.Combine(path,"character.json")))
                {
                    CustomCharacter charac = JsonConvert.DeserializeObject<CustomCharacter>(File.ReadAllText(Path.Combine(path, "character.json")));
                    charac.Scripts = DictionarizeGMLFolder(Path.Combine(path, "Scripts"));
                    Patcher.AddFileToCache(0, Path.Combine(path, "character.json"));
                    chars.Add(charac);
                }
            }
            return chars;
        }

        public static bool LoadCustomCharacters(string characterfolder)
        {
            try
            {
                CustomCharacters.AddRange(LoadCharacters(characterfolder));
                return true;
            }
            catch(Exception e)
            {
                Logger.Log(e.Message,Logger.LogLevel.Error);
                return false;
            }
        }


        


        public void Load(int audioGroup, UndertaleData data, ModData currentmod)
        {
            if (audioGroup != 0) return;
            #pragma warning disable CS8604
            string gmlfolder = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "GMLSource");
            string charactersfolder = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Characters");
            #pragma warning restore CS8604
            LoadCustomCharacters(charactersfolder);
            LoadGMLFolder(gmlfolder);

            LoadGMLFolder(Path.Combine(gmlfolder, "Scripts"));
        }

        public void LateLoad(int audioGroup, UndertaleData data, ModData currentMod)
        {
            if (audioGroup != 0) return;
            GDC = new GlobalDecompileContext(data, false);
            

            List<Menus.WysMenuOption> options = new List<Menus.WysMenuOption>();
            
            data.Code.ByName("gml_Object_obj_player_Create_0").AppendGmlSafe($@"
            if (!variable_global_exists(""current_character""))
            {{
                global.current_character = {CustomCharacters.IndexOf(CustomCharacters.First(x => x.id == DefaultCharacterID))};
            }}
            scr_autowhobble_ini()
            global.char_reset_ini = false", data);

            string cur_gml = GMLkvp["gml_Script_scr_move_like_a_snail_ini"];
            string cur_move_gml = GMLkvp["gml_Script_scr_move_like_a_snail"];
            string cur_draw_gml = GMLkvp["gml_Object_obj_player_Draw_0"];
            string cur_step_gml = "//INJECT";
            string cur_evil_draw_gml = "//INJECT";
            string cur_darkflare = GMLkvp["gml_Object_obj_darkFollowFlare_Step_0"];
            string cur_trail_part_color = "//INJECT";
            string cur_death_part_color = "//INJECT";
            string cur_flare_recolor = "//INJECT";
            string cur_spotlight = GMLkvp["gml_Object_obj_spotlight_drawer_Draw_0"];
            Dictionary<string,string> stupid_workaround = new Dictionary<string, string>();
            CreateScriptFromKVP(data, "scr_set_character", "gml_Script_scr_set_character", 1);
            
            for (int i = 0; i < CustomCharacters.Count; i++)
            {
                CustomCharacter curchar = CustomCharacters[i];
                if (DisabledIDs.Contains(curchar.id))
                {
                    continue;
                }
                options.Add(new Menus.WysMenuOption(new UndertaleString(curchar.name).ToString())
                {
                    tooltipScript = Menus.Vanilla.Tooltips.Text,
                    tooltipArgument = new UndertaleString(curchar.description).ToString(),
                    script = "scr_set_character",
                    scriptArgument = i.ToString()
                });
                if (!curchar.renderEyes)
                {
                    Conviences.PrependCode("gml_Object_obj_snaili_eye_Draw_0", $@"
                        if (global.current_character == {i})
                        {{
                            return false;
                        }}
                    ", data);
                }
                cur_move_gml = Injects.AttachInjectNoCharacter(cur_move_gml, $@"
                speed_multiplier = {curchar.speedMultiplier.ToString(CultureInfo.InvariantCulture)};
	            gravity_multiplier = {curchar.gravityMultiplier.ToString(CultureInfo.InvariantCulture)}
	            jump_multiplier = {curchar.jumpMultiplier.ToString(CultureInfo.InvariantCulture)}
	            jump_count = {curchar.jumps.ToString(CultureInfo.InvariantCulture)}
	            conveyor_multiplier = {curchar.conveyorMultiplier.ToString(CultureInfo.InvariantCulture)}
                underwater_friction = {curchar.underwaterFriction.ToString(CultureInfo.InvariantCulture)}
                trail_color = {curchar.trailColor}
                use_voice = {curchar.useSnailVoice.ToString().ToLower()}
                chbubble_scale = {curchar.bubbleScale.ToString(CultureInfo.InvariantCulture)}
                //INJECT CUSTOM MULTS", true, "//INJECT MULTIPLIERS", i.ToString());
                cur_move_gml = Injects.AttachInject(cur_move_gml, curchar, "Multipliers", false, "//INJECT CUSTOM MULTS", i.ToString(), false, false);
                cur_move_gml = Injects.AttachInject(cur_move_gml, curchar, "Override", true, "//INJECT COMPLETE OVERRIDE", i.ToString());
                cur_move_gml = Injects.AttachInject(cur_move_gml, curchar, "Jump", true, "//INJECT JUMP", i.ToString());
                cur_move_gml = Injects.AttachInject(cur_move_gml, curchar, "Physics", true, "//INJECT PHYSICS", i.ToString());
                cur_move_gml = Injects.AttachInject(cur_move_gml, curchar, "Collisions", true, "//INJECT COLLISIONS", i.ToString());
                cur_darkflare = Injects.AttachInjectNoCharacter(cur_darkflare, "image_blend = " + curchar.flareColor, true, "//INJECT", i.ToString());
                cur_flare_recolor = Injects.AttachInjectNoCharacter(cur_flare_recolor, GMLkvp["FlareColScript"].Replace("SNAILCOL",curchar.mainColor), true, "//INJECT", i.ToString());
                cur_trail_part_color = Injects.AttachInjectNoCharacter(cur_trail_part_color, "part_type_color1(global.part_type_playerTrail," + curchar.trailColor + ")", true, "//INJECT", i.ToString());
                cur_death_part_color = Injects.AttachInjectNoCharacter(cur_death_part_color, GMLkvp["DeathColScript"].Replace("DEATHCOL",curchar.deathColor), true, "//INJECT", i.ToString());
                cur_spotlight = Injects.AttachInjectNoCharacter(cur_spotlight, GMLkvp["SpotlightCol"].Replace("MAINCOL", curchar.mainColor).Replace("FLARECOL", curchar.flareColor), true, "//INJECT", i.ToString());
                cur_gml = Injects.AttachInject(cur_gml, curchar, "Initialization", false, "//INJECT", i.ToString());
                cur_step_gml = Injects.AttachInject(cur_step_gml, curchar, "StepEnd", true, "//INJECT", i.ToString());
                cur_draw_gml = Injects.AttachInject(cur_draw_gml, curchar, "Draw", true, "//INJECT", i.ToString());
                cur_evil_draw_gml = Injects.AttachInject(cur_evil_draw_gml, curchar, "Evil_Draw", true, "//INJECT", i.ToString());
                data.Code.ByName("gml_Object_obj_player_Create_0").AppendGmlSafe(curchar.Scripts.ContainsKey("Create") ? curchar.Scripts["Create"] : "", data);
                
                
                //Get all the Scripts in the character that begin with "Collision_"
                IEnumerable<KeyValuePair<string,string>> collision_scripts = curchar.Scripts.Where(x => x.Key.StartsWith("Collision_"));
                
                if (collision_scripts.Count() != 0)
                {
                    foreach (KeyValuePair<string, string> item in collision_scripts)
                    {
                        string ind = "gml_Object_obj_player_" + item.Key;
                        if (stupid_workaround.ContainsKey(ind))
                        {
                            stupid_workaround[ind] = Injects.AttachInject(stupid_workaround[ind], curchar, item.Key, false, "//INJECT", i.ToString());
                        }
                        else
                        {
                            stupid_workaround.Add(ind, Injects.AttachInject("//INJECT", curchar, item.Key, false, "//INJECT", i.ToString()));
                        }
                    }
                }
                
                
            }

            foreach (KeyValuePair<string,string> item in stupid_workaround)
            {
                data.HookCode(item.Key, item.Value + "\n#orig#()"); //only reason I do it like this is to keep consistency
            }

            data.Code.ByName("gml_Object_obj_player_Step_0").AppendGmlSafe("scr_autowhobble_update()\n" + cur_step_gml, data);

            data.Code.ByName("gml_Object_obj_player_Step_0").AppendGmlSafe(cur_trail_part_color, data);

            data.Code.ByName("gml_Object_obj_player_Step_0").AppendGmlSafe(cur_flare_recolor, data);
            
            data.Code.ByName("gml_Object_obj_player_Step_0").AppendGmlSafe(cur_death_part_color, data);


            data.Code.ByName("gml_GlobalScript_scr_move_like_a_snail_ini").ReplaceGmlSafe(cur_gml, data);

            data.Code.ByName("gml_Object_obj_spotlight_drawer_Draw_0").ReplaceGmlSafe(cur_spotlight, data);

            data.Code.ByName("gml_Object_obj_darkFollowFlare_Step_0").ReplaceGmlSafe(cur_darkflare, data);
            
            data.Code.ByName("gml_Object_obj_evil_snail_Draw_0").ReplaceGmlSafe(cur_evil_draw_gml, data);

            data.Code.ByName("gml_Object_obj_player_Draw_0").ReplaceGmlSafe(cur_draw_gml, data);
            

            data.Code.ByName("gml_GlobalScript_scr_move_like_a_snail").ReplaceGmlSafe(cur_move_gml, data);


            UndertaleGameObject charactersMenu = Menus.CreateMenu(data, "Mods",options.ToArray());

            Menus.InsertMenuOptionFromEnd(data, Menus.Vanilla.Gameplay, 1, new Menus.WysMenuOption("\"Characters\"")
            { 
                instance = charactersMenu.Name.Content
            });
            
            
        }
        
        public static UndertaleScript CreateScriptFromKVP(UndertaleData data, string name, string key, ushort arguments)
        {
            return data.CreateLegacyScript(name, GMLkvp[key], arguments);
        }
    }
}