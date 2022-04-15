using GmmlPatcher;
using UndertaleModLib;
using UndertaleModLib.Models;
using UndertaleModLib.Decompiler;
using System;

namespace WYSCustomCharacterAPI
{
    public static class Injects
    {

        public static string ReplaceCharacterEnums(string gml)
        {
            foreach (CustomCharacter chr in WYSCustomCharacterAPI.GameMakerMod.CustomCharacters)
            {
                gml = gml.Replace($"#char_{chr.id}#", WYSCustomCharacterAPI.GameMakerMod.CustomCharacters.IndexOf(chr).ToString());
            }
            return gml;
        }
        
        public static string AttachInject(string gml, CustomCharacter chara, string key, bool addconditional, string injectosearch, string enumreplace = "", bool failsafe = false, bool auto_add = true)
        {
            if (chara.overrideOnly && (key == "Jump" || key == "Physics" || key == "Collisions"))
            {
                Logger.Log("Ignoring key: " + key + " because overrideOnly is enabled", Logger.LogLevel.Debug);
                return ReplaceCharacterEnums(gml);
            }
            if (chara.Scripts.ContainsKey(key))
            {
                string to_add = addconditional == false ? chara.Scripts[key] : "if (global.current_character == ENUM_CHARACTERID)\n{\n" + chara.Scripts[key] + "\n}";
                gml = gml.Replace(injectosearch, to_add + (auto_add ? "\n" + injectosearch : ""));
                if (enumreplace != "")
                {
                    gml = gml.Replace("ENUM_CHARACTERID",enumreplace);
                }
            }
            else if (failsafe)
            {
                if (chara.parentCharacter != chara.id)
                {
                    return ReplaceCharacterEnums(AttachInject(gml, WYSCustomCharacterAPI.GameMakerMod.CustomCharacters.First(x => x.id == chara.parentCharacter), key, addconditional, injectosearch, enumreplace, true)); //go down the chain
                }
                Logger.Log("Failsafe does not have:" + key, Logger.LogLevel.Warn);
                return ReplaceCharacterEnums(gml);
            }
            else
            {
                return ReplaceCharacterEnums(AttachInject(gml, WYSCustomCharacterAPI.GameMakerMod.CustomCharacters.First(x => x.id == chara.parentCharacter), key, addconditional, injectosearch, enumreplace, true)); //default to the default character
            }
            return ReplaceCharacterEnums(gml);
        }
        
        public static string AttachInjectNoCharacter(string gml, string code, bool addconditional, string injectosearch, string enumreplace = "")
        {
            CustomCharacter fuck = new CustomCharacter();
            fuck.Scripts.Add("AMONGUS", code);

            return AttachInject(gml, fuck, "AMONGUS", addconditional, injectosearch, enumreplace);
        }


    }
}
