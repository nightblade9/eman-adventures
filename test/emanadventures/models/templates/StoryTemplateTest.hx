package emanadventures.models.templates;

import emanadventures.models.templates.StoryTemplate;
using haxesharp.collections.Linq;
import haxesharp.random.Random;
using haxesharp.text.StringExtensions;
import haxesharp.test.Assert;

@:access(emanadventures.models.templates.StoryTemplate)
class StoryTemplateTest
{
    @Test
    public function generateGeneratesARandomStory()
    {
        var r = new Random();
        var s1 = StoryTemplate.generate(r);
        Assert.that(s1, Is.not(null));
        Assert.that(s1.events, Is.not(null));
        Assert.that(s1.events.length > 0);

        // Make sure there are at least two stories. Object equality doesn't work,
        // so instad, check if the first event is the same. That is unique per-story.
        var s2:StoryTemplate;
        do
        {
            s2 = StoryTemplate.generate(r);
        } while (s2.events[0] == s1.events[0]);
    }

    @Test
    public function getTokensGetsUniqueTokens()
    {
        var template = new StoryTemplate([
            new EventTemplate("{Protagonist} discovers {Location}"),
            new EventTemplate("{Protagonist} discovers {NPC}"),
            new EventTemplate("{Protagonist} discovers {NPC::2}"),
            new EventTemplate("{Protagonist} discovers {NPC:Leader}"),
            new EventTemplate("{Protagonist} discovers {NPC:Warrior}"),
            new EventTemplate("{Protagonist} confronts {Antagonist}")            
        ]);

        var actual = template.getTokens();
        Assert.that(actual.length, Is.equalTo(7)); // Protagonist is repeated
        Assert.that(actual.where((s) => s == "{Protagonist}").length == 1);
        Assert.that(actual.where((s) => s == "{Location}").length == 1);
        Assert.that(actual.where((s) => s == "{Antagonist}").length == 1);
        // Tags and numbers are treated as unique
        Assert.that(actual.where((s) => s == "{NPC}").length == 1);
        Assert.that(actual.where((s) => s == "{NPC::2}").length == 1);
        Assert.that(actual.where((s) => s == "{NPC:Leader}").length == 1);
        Assert.that(actual.where((s) => s == "{NPC:Warrior}").length == 1);
    }

    @Test
    public function allStoryTokensHaveLocations()
    {

        for (template in StoryTemplate.ALL_TEMPLATES)
        {
            for (event in template.events)
            {
                if (!containsSpecialToken(event.data))
                {
                    Assert.that(event.data.contains("{Location"));
                }
            }
        }
    }

    private function containsSpecialToken(eventData:String):Bool
    {
        var specialTokens = ["Final Confrontation", "Epilogue:"];
        
        for (special in specialTokens)
        {
            if (eventData.contains(special))
            {
                return true;
            }
        }

        return false;
    }
}