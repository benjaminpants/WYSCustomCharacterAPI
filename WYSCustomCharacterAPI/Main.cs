using GmmlPatcher;
using UndertaleModLib;
using UndertaleModLib.Models;
using System;
using WysApi.Api;
using System.IO;
using Newtonsoft.Json;
using UndertaleModLib.Decompiler;
using System.Reflection;

namespace WYSCustomCharacterAPI
{
    
    public class CustomCharacter
    {
        public string id = "placeholder";
        public string name = "placeholder";
        public string description = "placeholder";
        public string trailColor = "c_white";
        public bool allowSnailLines = true;
        public bool useSlitherSound = true;
        public bool renderEyes = true;
        public double speedMultiplier = 1;
        public double underwaterFriction = 0.95;
        public double jumpMultiplier = 1;
        public double gravityMultiplier = 1;
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
            Dictionary<string, string> dict = DictionarizeGMLFolder(gmlfolder);
            foreach (KeyValuePair<string, string> kvp in dict)
            {
                GMLkvp.Add(kvp.Key, kvp.Value);
            }
            return dict.Count != 0;
        }

        public static List<CustomCharacter> LoadCharacters(string characterfolder)
        {
            List<CustomCharacter> chars = new List<CustomCharacter>();
            foreach (string path in Directory.GetDirectories(characterfolder))
            {
                if (File.Exists(Path.Combine(path,"character.json")))
                {
                    CustomCharacter charac = JsonConvert.DeserializeObject<CustomCharacter>(File.ReadAllText(Path.Combine(path, "character.json")));
                    charac.Scripts = DictionarizeGMLFolder(Path.Combine(path, "Scripts"));
                    chars.Add(charac);
                }
            }
            return chars;
        }


        public void Load(int audioGroup, ModData currentMod)
        {
            UndertaleData data = Patcher.data;
            if (audioGroup != 0) return;
            GDC = new GlobalDecompileContext(data, false);
            //supress vs being stupid
            #pragma warning disable CS8604
            string gmlfolder = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "GMLSource");
            string charactersfolder = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Characters");
            #pragma warning restore CS8604



            LoadGMLFolder(gmlfolder);

            LoadGMLFolder(Path.Combine(gmlfolder, "Scripts"));

            CustomCharacters = LoadCharacters(charactersfolder);


            List<Menus.WysMenuOption> options = new List<Menus.WysMenuOption>();
            
            data.Code.ByName("gml_Object_obj_player_Create_0").AppendGMLSafeSN("global.current_character = 0;",data);

            string cur_gml = GMLkvp["gml_Script_scr_move_like_a_snail_ini"];
            string cur_move_gml = GMLkvp["gml_Script_scr_move_like_a_snail"];

            for (int i = 0; i < CustomCharacters.Count; i++)
            {
                CustomCharacter curchar = CustomCharacters[i];
                options.Add(new Menus.WysMenuOption("\"" + curchar.name + "\"")
                {
                    tooltipScript = Menus.Vanilla.Tooltips.Text,
                    tooltipArgument = "\"" + curchar.description + "\""
                });
                if (!curchar.renderEyes)
                {
                    Conviences.PrependCode(data, "gml_Object_obj_snaili_eye_Draw_0", $@"
                        if (global.current_character == {i})
                        {{
                            return false;
                        }}
                    ");
                }
                cur_move_gml = Conviences.AttachInjectNoCharacter(cur_move_gml, $@"
                speed_multiplier = {curchar.speedMultiplier}
	            gravity_multiplier = {curchar.gravityMultiplier}
	            jump_multiplier = {curchar.jumpMultiplier}
	            jump_count = {curchar.jumps}
	            conveyor_multiplier = {curchar.conveyorMultiplier}
                underwater_friction = {curchar.underwaterFriction}
                trail_color = {curchar.trailColor}", true, "//INJECT MULTIPLIERS", i.ToString());
                cur_move_gml = Conviences.AttachInject(cur_move_gml, curchar, "Override", true, "//INJECT COMPLETE OVERRIDE", i.ToString());
                cur_gml = Conviences.AttachInject(cur_gml, curchar, "Initialization", false, "//INJECT", i.ToString());
                data.Code.ByName("gml_Object_obj_player_Create_0").AppendGMLSafeSN(curchar.Scripts["Create"] != null ? curchar.Scripts["Create"] : "//lol", data);
            }

            try
            {
                data.Code.ByName("gml_GlobalScript_scr_move_like_a_snail_ini").ReplaceGML(cur_gml, data);
            }
            catch (Exception)
            {

            }

            try
            {
                data.Code.ByName("gml_GlobalScript_scr_move_like_a_snail").ReplaceGML(cur_move_gml, data);
            }
            catch (Exception)
            {

            }



            UndertaleGameObject charactersMenu = Menus.CreateMenu("Mods",options.ToArray());

            Menus.InsertMenuOptionFromEnd(Menus.Vanilla.Gameplay, 1, new Menus.WysMenuOption("\"Characters\"")
            {
                instance = charactersMenu.Name.Content
            });


        }

        public static UndertaleScript CreateScriptFromKVP(UndertaleData data, string name, string key, ushort arguments)
        {
            return data.CreateScript(name, GMLkvp[key], arguments);
        }
    }
}