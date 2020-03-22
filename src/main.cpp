#include <iostream>
#include <unistd.h>

#include "upnp.h"
#include "ssdp.h"
#include "ssdpobserver.h"
#include "ssdpdbobserver.h"

class MainClass: public SSDPObserver, public SSDPDBObserver{
public:
    MainClass(SSDPDB* db, bool verbose) : db_(db), verbose_(verbose)
    {

    }

    int SSDPMessage(SSDPParser *parsedmsg){
        switch(parsedmsg->GetType()){
            case SSDP_TYPE_HTTP:
                //printf("SSDP_TYPE_HTTP\n");
                break;
            case SSDP_TYPE_NOTIFY:
                //printf("SSDP_TYPE_NOTIFY\n");
                break;
            case SSDP_TYPE_MSEARCH:
                //printf("SSDP_TYPE_MSEARCH\n");
                break;
            default:
                //printf("unknown\n");
                break;
        }
        return 0;
    }

    int SSDPDBMessage(SSDPDBMsg* msg){
        //SSDPDB* db = UPNP::GetInstance()->GetSSDP()->GetDB();
        switch(msg->type){
            case SSDPDBMsg_DeviceUpdate:
            case SSDPDBMsg_ServiceUpdate:
                if (verbose_)
                {
                  dump_results();
                }
                break;
        }
        return 0;
    }
    
    void dump_results()
    {
          db_->Lock();
          vector<SSDPDBDevice*>devices = db_->GetDevices();
          std::vector<SSDPDBDevice*>::iterator it;
          int x = 0;
          for(it=devices.begin();it<devices.end();it++){
              x++;
              printf("%.4d. full-usn=%s, type=%s, version=%s, location=%s\n", x, ((SSDPDBDevice*)*it)->usn.c_str(), ((SSDPDBDevice*)*it)->type.c_str(), ((SSDPDBDevice*)*it)->version.c_str(), ((SSDPDBDevice*)*it)->location.c_str());
          }
          db_->Unlock();
    }

private:
    SSDPDB* db_;
    bool verbose_;
};

void usage(char * app)
{
  std::cout << app << " [-t (default 5)]" << std::endl;
  std::cout << " -t : timeout, print results after listening for (t) seconds, 0 : keep listening and report every update." << std::endl;
}


int main(int argc, char *argv[])
{
    int timeout = 3;
    int c;
    while ( ((c = getopt( argc, argv, "t:?" ) ) ) != -1 )
    {
        switch (c)
        {
        case 't':
          timeout = atoi(optarg);
          break;
        case '?':
          default:
        usage(argv[0]);
        return -1;
        }
    }


    SSDP* ssdp = new SSDP();
    SSDPDB* db = ssdp->GetDB();
    MainClass mm(db, timeout==0);
    db->AddObserver(&mm);
    ssdp->AddObserver(&mm);
    ssdp->Start();
    
    int t = 0;
    while(timeout == 0 || t < timeout){
        ssdp->Search();
        sleep(timeout==0?15:1);
        t += 1;
    }

    mm.dump_results();

    delete(ssdp);

}


