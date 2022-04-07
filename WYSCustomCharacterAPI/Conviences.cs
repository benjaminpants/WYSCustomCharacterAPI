using GmmlPatcher;
using UndertaleModLib;
using UndertaleModLib.Models;
using UndertaleModLib.Decompiler;
using System;

namespace WYSCustomCharacterAPI
{
    public static class Conviences
    {

        //this is now just an alias, deprecation?
        public static UndertaleString CreateAndSaveString(this UndertaleData data, string str)
        {

            Logger.Log("Added string: " + str);

            return data.Strings.MakeString(str);
        }

        public static string DecompileGML(this UndertaleCode code)
        {

            Logger.Log("Decompiling: " + code.Name.Content);

            return Decompiler.Decompile(code, WYSCustomCharacterAPI.GameMakerMod.GDC);
        }

        public static UndertaleRoom.GameObject AddObjectToLayer(this UndertaleRoom room, UndertaleData data, string objectname, string layername)
        {
            data.GeneralInfo.LastObj++;
            UndertaleRoom.GameObject obj = new UndertaleRoom.GameObject()
            {
                InstanceID = data.GeneralInfo.LastObj,
                ObjectDefinition = data.GameObjects.ByName(objectname),
                X = 0,
                Y = 0
            };

            room.Layers.First(layer => layer.LayerName.Content == layername).InstancesData.Instances.Add(obj);

            room.GameObjects.Add(obj);

            return obj;
        }

        public static void AppendGMLSafe(this UndertaleCode code, string gml, UndertaleData data)
        {
            GmmlHooker.Hooker.AppendGmlSafe(code, gml); //CONFIG MAKE THIS AN EXTENSION METHOD

        }
        
        public static string AttachInject(string gml, CustomCharacter chara, string key, bool addconditional, string injectosearch, string enumreplace = "", bool failsafe = false)
        {
            if (chara.Scripts.ContainsKey(key))
            {
                string to_add = addconditional == false ? chara.Scripts[key] : "if (global.current_character == ENUM_CHARACTERID)\n{\n" + chara.Scripts[key] + "\n}";
                gml = gml.Replace(injectosearch, to_add + "\n" + injectosearch);
                if (enumreplace != "")
                {
                    gml = gml.Replace("ENUM_CHARACTERID",enumreplace);
                }
            }
            else if (failsafe)
            {
                Logger.Log("Failsafe does not have:" + key, Logger.LogLevel.Warn);
                return gml;
            }
            else
            {
                return AttachInject(gml, WYSCustomCharacterAPI.GameMakerMod.CustomCharacters.First(x => x.id == "shelly"), key, addconditional, injectosearch, enumreplace, true); //default to shelly
            }
            return gml;
        }
        
        public static string AttachInjectNoCharacter(string gml, string code, bool addconditional, string injectosearch, string enumreplace = "")
        {
            CustomCharacter fuck = new CustomCharacter();
            fuck.Scripts.Add("AMONGUS", code);

            return AttachInject(gml, fuck, "AMONGUS", addconditional, injectosearch, enumreplace);
        }

        public static void PrependCode(UndertaleData data, string name, string gml)
        {
            UndertaleCode code = data.Code.First(c => c.Name.Content == name);
            if (code != null)
            {
                string newcode = gml + "\n" + code.DecompileGML();
                try
                {
                    code.ReplaceGML(newcode, data);
                }
                catch (Exception) {/* die */}
            }
        }

        public static UndertaleCode CreateCode(this UndertaleData data, string name, string gml, ushort arguments = 0)
        {
            UndertaleCode code = new UndertaleCode();
            code.Name = data.CreateAndSaveString(name);
            try
            {
                code.AppendGML(gml, data);
            }
            catch (Exception) { };
            code.ArgumentsCount = arguments;

            data.Code.Add(code);

            return code;
        }

        public static UndertaleScript CreateScript(this UndertaleData data, string scriptname, string gml, ushort arguments = 0)
        {
            UndertaleScript scr = new UndertaleScript();
            UndertaleCode code = new UndertaleCode();
            scr.Name = data.CreateAndSaveString(scriptname);
            try
            {
                code.AppendGML(gml, data);
            }
            catch (Exception) { };
            code.ArgumentsCount = arguments;
            scr.Code = code;

            code.Name = data.CreateAndSaveString("GlobalScript_" + scriptname);

            data.Code.Add(code);

            data.Scripts.Add(scr);

            Logger.Log("Added script: " + scriptname);

            return scr;

        }

    }
}
