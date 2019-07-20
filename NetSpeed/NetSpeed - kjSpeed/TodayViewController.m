//
//  TodayViewController.m
//  网速大师傅
//
//  Created by 杨科军 on 2018/11/9.
//  Copyright © 2018 杨科军. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import <sys/sysctl.h>
#import <mach/mach.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>
#import "WMGaugeView.h"
#import "Reachability.h"

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UILabel *menoryLab;
@property (weak, nonatomic) IBOutlet UILabel *diskLab;

@property (weak, nonatomic) IBOutlet UILabel *topLiuLiang;
@property (weak, nonatomic) IBOutlet UILabel *downLiuLiang;
@property (weak, nonatomic) IBOutlet UILabel *cpuLab;
@property (weak, nonatomic) IBOutlet WMGaugeView *guanGeView;
@property (weak, nonatomic) IBOutlet UILabel *memoryPreLab;

// 网速
@property (assign, nonatomic) float preWWAN_R;
@property (assign, nonatomic) float preWWAN_S;
@property (assign, nonatomic) float preWifi_R;
@property (assign, nonatomic) float preWifi_S;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int preRef;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self currentLiuLiang];
    [self setAppearance];
//    [self refreshV];
    
    float availableMemory = [self availableMemory];
    self.menoryLab.text = [NSString stringWithFormat:@"%.0f MB", availableMemory];
    
    float allMemory = [self getTotalMemorySize];
    float memoryPre = (1-availableMemory/allMemory)*100;    
    self.guanGeView.value = memoryPre;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshV) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshV) userInfo:nil repeats:YES];
    //    self.timer = timer;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"disOver");
    [self.timer invalidate];
    self.timer = nil;
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    NSLog(@"ove");
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;        
    }
}

- (void)setAppearance {
    self.guanGeView.maxValue = 100.0;
    self.guanGeView.scaleDivisions = 10;
    self.guanGeView.scaleSubdivisions = 5;
    self.guanGeView.scaleStartAngle = 60;
    self.guanGeView.scaleEndAngle = 300;
    self.guanGeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    self.guanGeView.showScaleShadow = NO;
    self.guanGeView.scalesubdivisionsaligment = WMGaugeViewSubdivisionsAlignmentCenter;
    self.guanGeView.scaleSubdivisionsWidth = 0.002;
    self.guanGeView.scaleSubdivisionsLength = 0.04;
    self.guanGeView.scaleDivisionsWidth = 0.007;
    self.guanGeView.scaleDivisionsLength = 0.07;
    self.guanGeView.needleStyle = WMGaugeViewNeedleStyle3D;
    self.guanGeView.needleWidth = 0.012;
    self.guanGeView.needleHeight = 0.4;
    self.guanGeView.needleScrewStyle = WMGaugeViewNeedleScrewStyleGradient;
    self.guanGeView.needleScrewRadius = 0.05;
}

- (void)refreshV {
    //    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.gsMonitorDemo"];
    //    float availableMemory = [userDefaults floatForKey:@"group.availableMemory"];
    
    // 内存、存储
    float availableMemory = [self availableMemory];
    self.menoryLab.text = [NSString stringWithFormat:@"%.0f MB", availableMemory];
    
    float allMemory = [self getTotalMemorySize];
    float memoryPre = (1-availableMemory/allMemory)*100;
    self.memoryPreLab.text = [NSString stringWithFormat:@"%.2f %%", memoryPre];
    if (self.preRef % 2 == 0) {
//        NSLog(@"%f", memoryPre);
        self.guanGeView.value = memoryPre;
        if (self.preRef == 100) {
            self.preRef = 0;
        }
    }
    self.preRef ++;
    
    float availableDiskSize = [self getAvailableDiskSize];
    self.diskLab.text = [NSString stringWithFormat:@"%.1f GB", availableDiskSize / 1024.0];
    
    // 上行、下行流量
    Reachability *reachability = [Reachability reachabilityWithHostName:@"hha"];
    if (reachability.currentReachabilityStatus == ReachableViaWiFi) {
        float wifiS_preSecond = [[self getDataCounters][0] floatValue] - self.preWifi_S;
        float wifiR_preSecond = [[self getDataCounters][1] floatValue] - self.preWifi_R;
        self.topLiuLiang.text = [NSString stringWithFormat:@"%.1f KB/s", wifiS_preSecond];
        self.downLiuLiang.text = [NSString stringWithFormat:@"%.1f KB/s", wifiR_preSecond];
    }else if(reachability.currentReachabilityStatus == ReachableViaWWAN) {
        float wwanS_preSecond = [[self getDataCounters][2] floatValue] - self.preWWAN_S;
        float wwanR_preSecond = [[self getDataCounters][3] floatValue] - self.preWWAN_R;
        self.topLiuLiang.text = [NSString stringWithFormat:@"%.1f KB/s", wwanS_preSecond];
        self.downLiuLiang.text = [NSString stringWithFormat:@"%.1f KB/s", wwanR_preSecond];
    }
    
    [self currentLiuLiang];
    
    float cpuUsage = [self cpu_usage];
    self.cpuLab.text = [NSString stringWithFormat:@"%.1f%%", cpuUsage];
}

// 赋值当前流量
- (void)currentLiuLiang {
    NSNumber *wifiSendNumber = [self getDataCounters][0];
    float wifiS = [wifiSendNumber floatValue];
    self.preWifi_S = wifiS;
    
    NSNumber *wifiReceived = [self getDataCounters][1];
    float wifiR = [wifiReceived floatValue];
    self.preWifi_R = wifiR;
    
    NSNumber *wwanSendNumber = [self getDataCounters][2];
    float wwanS = [wwanSendNumber floatValue];
    self.preWWAN_S = wwanS;
    
    NSNumber *wwanReceived = [self getDataCounters][3];
    float wwanR = [wwanReceived floatValue];
    self.preWWAN_R = wwanR;
}

// 获取当前设备可用内存(单位：MB）
- (float)availableMemory{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取总内存大小
- (float)getTotalMemorySize{
    return [NSProcessInfo processInfo].physicalMemory / 1024.0 / 1024.0;
}

// 获取当前设备可用存储(单位：MB）
- (float)getAvailableDiskSize{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0){
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace / 1024.0 / 1024.0;
}

// 上行、下行流量
- (NSArray *)getDataCounters{
    BOOL success;
    struct ifaddrs *addrs;
    struct ifaddrs *cursor;
    struct if_data *networkStatisc;
    int WiFiSent = 0,WiFiReceived = 0,WWANSent = 0,WWANReceived = 0;
    NSString *name = [[NSString alloc]init];
    success = getifaddrs(&addrs) == 0;
    if (success){
        cursor = addrs;
        while (cursor != NULL){
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            //NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK){
                if ([name hasPrefix:@"en"]){
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                    //NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    //NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                if ([name hasPrefix:@"pdp_ip"]){
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                    //NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    //NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent/1024], [NSNumber numberWithInt:WiFiReceived/1024],[NSNumber numberWithInt:WWANSent/1024],[NSNumber numberWithInt:WWANReceived/1024], nil];
}

// cpu
- (float)cpu_usage{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++){
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

@end
