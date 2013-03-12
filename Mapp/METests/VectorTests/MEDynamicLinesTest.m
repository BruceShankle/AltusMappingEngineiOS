#import "MEDynamicLinesTest.h"

@implementation MEDynamicLinesTest
{
    NSMutableArray* _sourcePoints;
    double _time;
}

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Dynamic Vector Lines";
        
        _time = 0;
        
        //Create an array of points for a polygon
        _sourcePoints=[[NSMutableArray alloc]init];
        
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4000520394454, 37.80231524067277)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4008027390959, 37.80314794952178)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4019179210528, 37.80429824982496)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4033134210884, 37.80537983727451)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4046315823453, 37.80632306321804)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.406912638841, 37.80739079535009)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4073267591124, 37.80754510351845)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4077760000761, 37.80769511166064)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4084828527564, 37.80800292998484)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4089368510862, 37.80818655549997)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4091357360793, 37.80824470189145)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4093793277758, 37.80828016428843)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4097876942285, 37.80830867220114)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4099680306485, 37.80832523188914)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4104087573531, 37.80837297015927)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4109793856165, 37.80845179677753)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4116997633032, 37.80856310098702)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4123383222213, 37.80865732224046)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4125322096654, 37.80868111254854)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4125093960089, 37.80851322997533)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4124907768879, 37.80837050138439)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4123931864527, 37.80788426669736)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4123753075017, 37.80780286826502)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4124488868394, 37.80777388169007)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4126975299311, 37.80773709959325)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4133355084509, 37.80765584738416)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4138004633809, 37.80759745915129)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4140076450411, 37.80758347043385)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4139501341257, 37.80734993437279)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4138278937926, 37.80676294903351)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4138077758, 37.80664091104169)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4141872998007, 37.80659055044461)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4148888178647, 37.80650204756711)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4152869345653, 37.80644879799485)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4154608602905, 37.8064335126343)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4153552099951, 37.80602746106798)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4152912036825, 37.80569786006821)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4152689494762, 37.80552255018563)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4154732658995, 37.80549688180041)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4162540487749, 37.80539906207984)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4167574522322, 37.80534846318346)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4170675863929, 37.8052954410469)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4171594527784, 37.80528274511691)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4172359381955, 37.80530442424793)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4174554269393, 37.80548123866435)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.417824162424, 37.8057287933146)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4181301861336, 37.80594370472875)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4185191712581, 37.80617407108333)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4190968710037, 37.8065620135585)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4193957119565, 37.80677231078239)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4195401411641, 37.80687497732036)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4198104797165, 37.8068439643467)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4203587240063, 37.80678315495452)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4207510027504, 37.80673587242929)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4219649033527, 37.80657673463459)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4224244736436, 37.80649963978672)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4232923245204, 37.80638334938628)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4237890672511, 37.80632652545588)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4238623360662, 37.80626633787337)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4238386704556, 37.80611474896816)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4237332719385, 37.8057197404195)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4236918917879, 37.8054315194831)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.423639516907, 37.80519527066082)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4234194109299, 37.80422412120496)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4232910114815, 37.8035972209826)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.423109067042, 37.8026566678953)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4229727904945, 37.80166143689382)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4227873036549, 37.80070452904073)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4226031960185, 37.7997746174938)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4222139330641, 37.7979299523826)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4220420735974, 37.79700738796059)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4218548230183, 37.79606763948196)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4206799037019, 37.79061014208995)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4196256181375, 37.78551727697793)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4189545894873, 37.78221998491583)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.420636316395, 37.78200215335735)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4204627790474, 37.7810105123929)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4199220484326, 37.77824278160602)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4195297669761, 37.77635217399141)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4192722060991, 37.77498394893562)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4187398621987, 37.77315789185153)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.418101346931, 37.77115661461404)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4179159059127, 37.77062604660386)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.417799542003, 37.77050307407399)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4177089632151, 37.77039349588907)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4177183407215, 37.77023983512625)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4178714563951, 37.76915205352007)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4178553266866, 37.76852829178636)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4177036591522, 37.76685268310507)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4176873352171, 37.76677165778878)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4154741069142, 37.76692181996404)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4133337486129, 37.76702657357414)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4131943137293, 37.76541880957922)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.407597345935, 37.76579573518643)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4046619722886, 37.7659908849816)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.4006990080993, 37.76617516286571)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3951225167131, 37.76651862376567)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3948488176549, 37.76651721622289)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.394223138708, 37.76598455379403)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3938377549415, 37.76552261752515)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3933722681413, 37.76464361126502)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3931237097803, 37.76383464426378)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3930371800162, 37.76313426568223)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3930809437981, 37.76304090171212)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3931661041773, 37.76298092068229)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3932971059652, 37.76294996819661)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3934160336705, 37.76296980221979)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3935425407668, 37.76306015791923)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.393579661427, 37.76320550070182)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3936319878428, 37.76347337017131)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3936958699167, 37.76401382958487)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3939548871468, 37.7640346412548)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3946641297084, 37.76399153090902)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3956392509929, 37.76393404389027)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3955795315211, 37.76263992886951)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.395478387239, 37.76135367818121)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3953453300694, 37.76009381214332)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3951977578301, 37.75843972768789)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3951348518045, 37.75804307756816)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3946288524507, 37.75755292533348)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3932875989637, 37.75762530195993)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3911705152445, 37.75776464398904)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3883160316958, 37.7579294087464)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3872986184547, 37.75800044761694)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3874927813898, 37.7598707030741)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3875586577545, 37.7605668308691)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3894816537624, 37.76046614959265)]];
        [_sourcePoints addObject:[NSValue valueWithCGPoint:CGPointMake(-122.3895893946106, 37.76169051025676)]];
        
    }
    return self;
}

- (void) dealloc
{
    [_sourcePoints release];
    [super dealloc];
}

- (void) start
{
    //Add an in-memory vector map
	MEVectorMapInfo* vectorMapInfo = [[[MEVectorMapInfo alloc]init]autorelease];
	vectorMapInfo.name = self.name;
	vectorMapInfo.zOrder = 100;
	[self.meMapViewController addMapUsingMapInfo:vectorMapInfo];
	
    
	[self lookAtSanFrancisco];
    //Set timer interval
    self.interval = 0.016;
    
    //Start test / timer
    [super start];
}

- (void) stop
{
    [self.meMapViewController removeMap:self.name clearCache:NO];
    [super stop];
}

- (void) timerTick
{
    _time += 0.016;
    
    [self.meMapViewController clearDynamicGeometryFromMap:self.name];
    
    
    NSMutableArray *points =[[[NSMutableArray alloc]init]autorelease];
    for(NSValue* value in _sourcePoints)
    {
        CGPoint point = value.CGPointValue;
        point.x += 0.01 * _time;
        [points addObject:[NSValue valueWithCGPoint:point]];
    }

    //Create a new line style
    MELineStyle* lineStyle=[[[MELineStyle alloc]init]autorelease];
    UIColor* black = [[[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:1.0]autorelease];
    lineStyle.strokeColor = black;
    lineStyle.strokeWidth = 6;
    
    //Add the line to the map
    [self.meMapViewController addDynamicLineToVectorMap:self.name lineId:@"route" points:points style:lineStyle];
    
    //Add line again with different size (so we see outline)
    lineStyle.strokeColor = [UIColor greenColor];
    lineStyle.strokeWidth = 4;
    [self.meMapViewController addDynamicLineToVectorMap:self.name lineId:@"routeOutline" points:points style:lineStyle];
}


@end
