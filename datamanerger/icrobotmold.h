#ifndef ICROBOTMOLD_H
#define ICROBOTMOLD_H

#include <QtGlobal>
#include <QString>
#include <QSharedPointer>
#include <QVector>
#include "icconfigsaddr.h"
#include "icparameterscache.h"
#include "icdalhelper.h"

class IRobotMoldError:public QObject
{
    Q_OBJECT
    Q_PROPERTY(int errno READ errno WRITE setErrno NOTIFY errnoChanged)
    Q_PROPERTY(QString errString READ errString WRITE setErrString NOTIFY errStringChanged)

signals:
    void errnoChanged(int);
    void errStringChanged(QString);
public:
    IRobotMoldError(int errno, const QString& errStr):
        errno_(errno),
        errStr_(errStr){}

    int errno() const { return errno_;}
    void setErrno(int errno) { errno_ = errno;}

    QString errString() const { return errStr_;}
    void setErrString(const QString& errStr) { errStr_ = errStr;}

private:
    int errno_;
    QString errStr_;
};


class ICMoldItem
{
public:
    ICMoldItem():
        seq_(0),
        num_(0),
        subNum_(-1),
        gmVal_(0),
        pos_(0),
        ifVal_(0),
        ifPos_(0),
        sVal_(0),
        dVal_(0),
        flag_(0),
        sum_(0){}

    uint Seq() const { return seq_;}    //序号
    void SetSeq(uint seq) { seq_ = seq; }
    uint Num() const { return num_;}  //步序
    void SetNum(uint nVal) { num_ = nVal; }
    quint8 SubNum() const { return subNum_;}
    void SetSubNum(int num) { subNum_ = num;}
    uint GMVal() const { return gmVal_;}    //类别区分，0是动作组，1是夹具组
    void SetGMVal(uint gmVal) { gmVal_ = gmVal; }
    bool IsAction() const { return (!(GMVal() & 0x80));}
    bool IsClip() const { return GMVal() & 0x80;}
    bool IsEarlyEnd() const { return (IFVal() & 0x80 ) == 0x80;}
    bool IsEarlySpeedDown() const { return (IFVal() & 0x20 ) == 0x20;}

    uint GetEarlyDownSpeed() const { return (IFVal() & 0x1F );}
    void SetEarlyEnd(bool earlyEnd) { earlyEnd ? ifVal_ |= 0x80 : ifVal_ &= 0x7F;}
    void SetEarlySpeedDown(bool earlySpeedDown) { earlySpeedDown ? ifVal_ |= 0x20 : ifVal_ &= 0xDF;}
    void SetEarlyDownSpeed(uint earlyDownSpeed) {ifVal_ = (ifVal_ & ~(0x1f)) | (earlyDownSpeed & 0x1F);}
    bool IsBadProduct() const { return (IFVal() & 0x40) == 0x40;}
    void SetBadProduct(bool badProduct) { badProduct ? ifVal_ |= 0x40 : ifVal_ &= 0xBF;}
    uint IFOtherVal() const { return IFVal() & 0x1F;}
    void SetIFOtherVal(uint val) { ifVal_ &= 0xE0; ifVal_ |= (val & 0x1F);}
    uint Action() const
    {
        if(!IsAction())
        {
            return 0;
        }
        return GMVal() & 0x7F;
    }
    void SetAction(uint action)
    {
        gmVal_ = action;
    }

    uint Clip() const
    {
        if(!IsClip())
        {
            return 0;
        }
        return GMVal() & 0x7F;
    }
    void SetClip(uint clip)
    {
        gmVal_ = clip;
        gmVal_ |= 0x80;
    }

    int Pos() const { return pos_;}    //X位置
    void SetPos(int pos) { pos_ = pos; }
    uint IFVal() const { return ifVal_;}
    void SetIFVal(uint val) { ifVal_ = val; }
    uint IFPos() const { return ifPos_;}
    void SetIFPos(uint pos) { ifPos_ = pos;}


    uint SVal() const { return sVal_;}  //速度，在clip中是次数，堆叠中是选择

    void SetSVal(uint sVal) { sVal_ = sVal; }
    uint DVal() const { return dVal_;}  //延时
    void SetDVal(uint dVal) { dVal_ = dVal; }


    uint Sum() const { return sum_;}  //
    uint ReSum() const
    {
        int sum = seq_ + num_ + subNum_ + gmVal_ + pos_ + ifVal_ + ifPos_ + sVal_ + dVal_;
        while(sum & 0xFF00)
        {
            sum = ((sum >> 8) & 0x00FF) + (sum & 0x00FF);
        }
        sum_ = sum;
        return sum_;
    }

    void SetValue(uint seq,
                  uint num,
                  quint8 subNum,
                  uint gmVal,
                  uint pos,
                  uint ifVal,
                  uint ifPos,
                  uint sVal,
                  uint dVal,
                  uint sum)
    {
        seq_ = seq;
        num_ = num;
        subNum_ = subNum;
        gmVal_ = gmVal;
        pos_ = pos;
        ifVal_ = ifVal;
        ifPos_ = ifPos;
        sVal_ = sVal;
        dVal_ = dVal;
        sum_ = sum;
    }
    QByteArray ToString() const
    {
        QByteArray ret;

        QString tmp = (QString().sprintf("%u %u %u %u %u %u %u %u %u %u ",
                                         seq_, num_, subNum_, gmVal_, pos_, ifVal_, ifPos_, sVal_, dVal_, sum_));

        tmp += QString::number(flag_);
        tmp += " ";
        tmp += comment_;
        ret = tmp.toUtf8();
        return ret;
    }
    QVector<quint32> ToDataBuffer() const
    {
        QVector<quint32> ret;
        ret<<(quint16)seq_<<(quint16)num_<<(quint16)((subNum_<< 8) | gmVal_)<<(quint16)pos_
          <<(quint16)((ifVal_<< 8) | (ifPos_>>8))<<(quint16)(((ifPos_ & 0xFF) << 8) | (dVal_ >> 8))
            <<(quint16)(((dVal_ & 0xFF) << 8) | sVal_)<<(quint16)sum_;
        return ret;
    }

    int ActualPos() const
    {
        return (QString::number(Pos()) + QString::number(IFPos() & 0xF)).toInt();
    }
    void SetActualPos(int pos)
    {
        int p = pos / 10;
        int d = pos % 10;
        SetPos(p);
        ifPos_ &= 0xFFFFFFF0;
        ifPos_ |= d;
    }

    int ActualIfPos() const
    {
        return IFPos() >> 4;
    }

    void SetActualIfPos(uint pos)
    {
        ifPos_ &= 0x0000000F;
        ifPos_ |= (pos << 4);
    }

    int ActualMoldCount() const
    {
        return ((IFPos() & 0xFF) << 8) | SVal();
    }

    void SetActualMoldCount(uint count)
    {
//        SetIFVal((count >> 8) & 0xFF);
        ifPos_ &= 0xFFFFFF00;
        ifPos_ |= (count >> 8) & 0xFF;
        SetSVal(count & 0xFF);
    }

    QString Comment() const { return comment_;}
    void SetComment(const QString& comment) { comment_ = comment;}

    int Flag() const { return flag_;}
    void SetFlag(int flag) { flag_ = flag;}

private:
    uint seq_;
    uint num_;
    quint8 subNum_;
    uint gmVal_;
    int pos_;
    uint ifVal_;
    uint ifPos_;
    uint sVal_;
    uint dVal_;
    QString comment_;
    int flag_;
    mutable uint sum_;
};

typedef QList<ICMoldItem> ICActionProgram;

class ICRobotMold;

typedef QSharedPointer<ICRobotMold> ICRobotMoldPTR;
class ICRobotMold
{
public:
    enum {
        kMainProg,
        kSub1Prog,
        kSub2Prog,
        kSub3Prog,
        kSub4Prog,
        kSub5Prog,
        kSub6Prog,
        kSub7Prog,
        kSub8Prog,

    };

    enum
    {
        GC          =0,		//0
        GX,			//1
        GY,			//2
        GZ,			//3
        GP,			//4
        GQ,			//5
        GA,			//6
        GB,			//7

        ACTMAINUP,		//8
        ACTMAINDOWN,	//9
        ACTMAINFORWARD,	//10
        ACTMAINBACKWARD,//11

        ACTPOSEHORI,	//12   水平1
        ACTPOSEVERT,	//13   垂直1
        ACTVICEUP,		//14
        ACTVICEDOWN,	//15

        ACTVICEFORWARD,	//16
        ACTVICEBACKWARD,//17
        ACTGOOUT,		//18
        ACTCOMEIN,		//19

        ACT_PoseHori2,		//20  水平2
        ACT_PoseVert2,   //21  垂直2

        ACT_GASUB,
        ACT_GAADD,
        ACT_GBSUB,
        ACT_GBADD,
        ACT_GCSUB,
        ACT_GCADD,

        ACT_OTHER = 27,
        ACTCHECKINPUT=28,
        ACT_WaitMoldOpened = 29,
        ACT_Cut,
        ACTParallel = 31,
        ACTEND,
        ACTCOMMENT
    };

    ICRobotMold();
    static ICRobotMoldPTR CurrentMold()
    {
        return currentMold_;
    }
    static void SetCurrentMold(ICRobotMold* mold)
    {
        currentMold_ = ICRobotMoldPTR(mold);
    }

    static ICRecordInfos RecordInfos()
    {
        return ICDALHelper::RecordTableInfos();
    }

    static RecordDataObject NewRecord(const QString& name,
                                      const QString& initProgram,
                                      const QList<QPair<int, quint32> >& values);


    static ICActionProgram Complie(const QString& programText);

    static QString ActionProgramToStore(const ICActionProgram& program);

    static void AddCheckSumToAddrValuePairList(QList<QPair<int, quint32> >& values)
    {
        quint32 checkSum = 0;
        for(int i = 0; i != values.size(); ++i)
        {
            checkSum += values.at(i).second;
        }
        checkSum = (-checkSum) & 0xFFFF;
        values.append(qMakePair(values.last().first + 1, checkSum));
    }

    QVector<quint32> ProgramToDataBuffer(int program) const
    {
        QVector<quint32> ret;
        ICActionProgram p = programs_[program];
        for(int i = 0; i != p.size(); ++i)
        {
            ret += p.at(i).ToDataBuffer();
        }
        return ret;
    }

    QVector<quint32> MoldFncsBuffer() const
    {
        return fncCache_.SequenceDataList();
    }

    bool LoadMold(const QString& moldName);

    quint32 MoldFnc(ICAddrWrapperCPTR addr)
    {
        return fncCache_.ConfigValue(addr);
    }

    void SetMoldFncs(const ICAddrWrapperValuePairList values);

private:
    ICActionProgram ParseActionProgram_(const QString& content);

private:
    QList<ICActionProgram> programs_;
    static ICRobotMoldPTR currentMold_;
    QString moldName_;
    ICParametersCache fncCache_;
};

#endif // ICROBOTMOLD_H
