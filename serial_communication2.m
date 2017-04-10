function varargout = serial_communication2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @serial_communication2_OpeningFcn, ...
                   'gui_OutputFcn',  @serial_communication2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function serial_communication2_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
warning off all;

%% ��ʼ������
hasData = false; %���������Ƿ���յ�����
isShow = false;  %�����Ƿ����ڽ���������ʾ�����Ƿ�����ִ�к���dataDisp
strRec = '';   %�ѽ��յ��ַ���
global  i;%% ������������ΪӦ�����ݣ����봰�ڶ�����
i=1;
setappdata(hObject, 'hasData', hasData);
setappdata(hObject, 'strRec', strRec);
setappdata(hObject, 'isShow', isShow);
setappdata(hObject,'databuf',0);
setappdata(hObject,'databuf1',0);
setappdata(hObject,'databuf2',0);
setappdata(hObject,'time',0);
guidata(hObject, handles);

%%���ĵ����⣬���ù�
function varargout = serial_communication2_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function com_Callback(hObject, ~, handles)

function com_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rate_Callback(hObject, eventdata, handles)

function rate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function jiaoyan_Callback(hObject, eventdata, handles)

function jiaoyan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function data_bits_Callback(hObject, eventdata, handles)

function data_bits_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stop_bits_Callback(hObject, eventdata, handles)

function stop_bits_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%��/�رմ��ڻص�
function start_serial_Callback(hObject, eventdata, handles)
if get(hObject, 'value')==1
    com_n = sprintf('com%d', get(handles.com, 'value'));
    rates = [300 600 1200 2400 4800 9600 19200 38400 43000 56000 57600 115200];
    baud_rate = rates(get(handles.rate, 'value'));
    switch get(handles.jiaoyan, 'value')
        case 1
            jiaoyan = 'none';
        case 2
            jiaoyan = 'odd';
        case 3
            jiaoyan = 'even';
    end
    data_bits = 5 + get(handles.data_bits, 'value');
    stop_bits = get(handles.stop_bits, 'value');
    scom = serial(com_n);
    set(scom, 'BaudRate', baud_rate, 'Parity', jiaoyan, 'DataBits',...
        data_bits, 'StopBits', stop_bits, 'BytesAvailableFcnCount', 10,...
        'BytesAvailableFcnMode', 'byte', 'BytesAvailableFcn', {@bytes, handles},...
        'TimerPeriod', 0.05, 'timerfcn', {@dataDisp, handles});

    set(handles.figure1, 'UserData', scom);

    try
        fopen(scom);
    catch
        msgbox('�����޷��򿪣�');
        set(hObject, 'value', 0);
        return;
    end

    set(handles.xianshi, 'string', '');
    set(hObject, 'String', '�رմ���');
    set(hObject,'value',1);
else
    t = timerfind;
    if ~isempty(t)
        stop(t);
        delete(t);
    end
    scoms = instrfind;
    stopasync(scoms);
    fclose(scoms);
    delete(scoms);

    set(hObject, 'String', '�򿪴���');
    set(hObject,'value',0);
end

function dataDisp(obj, event, handles)
global value
global thr 
global wz_acc
global height
%	���ڵ�TimerFcn�ص�����
%   ����������ʾ
%% ��ȡ����
hasData = getappdata(handles.figure1, 'hasData'); %�����Ƿ��յ�����
strRec = getappdata(handles.figure1, 'strRec');   %�������ݵ��ַ�����ʽ����ʱ��ʾ������
numRec = getappdata(handles.figure1, 'numRec');   %���ڽ��յ������ݸ���
%% �����������ݣ���ʾ��������
if hasData
    %% ��������ʾģ��ӻ�����
    %% ��ִ����ʾ����ģ��ʱ�������ܴ������ݣ�����ִ��BytesAvailableFcn�ص�����
    setappdata(handles.figure1, 'isShow', true); 
    
    %% ��Ҫ��ʾ���ַ������ȳ���10000�������ʾ��
    if length(strRec) > 10000
        strRec = '';
        setappdata(handles.figure1, 'strRec', strRec);
    end
    set(handles.xianshi, 'string', strRec);
    
    databuf=getappdata(handles.figure1,'datbuf');
    databuf1=getappdata(handles.figure1,'datbuf1');
    databuf2=getappdata(handles.figure1,'datbuf2');
    time=getappdata(handles.figure1,'time');
    
    axes(handles.thr);   
    plot(handles.thr,databuf);   
    save thr.txt databuf -append -ascii;
    set(handles.thr1, 'string', databuf);
  
    
    axes(handles.speed);
    plot(handles.speed,databuf1);
      save wz_acc.txt databuf1 -append -ascii;
      set(handles.speed1, 'string', databuf1);
  
   
    axes(handles.Height);
    plot(handles.Height,databuf2);
     save Height.txt databuf2 -append -ascii;
     set(handles.height1, 'string', databuf2);
  
    
    %% ����hasData��־���������������Ѿ���ʾ
    setappdata(handles.figure1, 'hasData', false);
    %% ��������ʾģ�����
    setappdata(handles.figure1, 'isShow', false);
    
    
end
 
function bytes(obj, ~, handles)
%   ���ڵ�BytesAvailableFcn�ص�����
%   ���ڽ�������
%% ��ȡ����
strRec = getappdata(handles.figure1, 'strRec'); %��ȡ����Ҫ��ʾ������
numRec = getappdata(handles.figure1, 'numRec'); %��ȡ�����ѽ������ݵĸ���
isShow = getappdata(handles.figure1, 'isShow');  %�Ƿ�����ִ����ʾ���ݲ���
    databuf=getappdata(handles.figure1,'datbuf');
    databuf1=getappdata(handles.figure1,'datbuf1');
    databuf2=getappdata(handles.figure1,'datbuf2');
    time=getappdata(handles.figure1,'time');

%% ������ִ��������ʾ�������ݲ����մ�������
if isShow
    return;
end
%% ��ȡ���ڿɻ�ȡ�����ݸ���
n = get(obj, 'BytesAvailable');
%% �����������ݣ�������������
if n
    %% ����hasData����������������������Ҫ��ʾ
    setappdata(handles.figure1, 'hasData', true);
    %% ��ȡ��������
    a = fread(obj, n, 'uchar');
    state=0;
    data=0;
    len=length(a);
   % save thr.txt len -append -ascii;
    for i=1:1:len
        val=a(i);
      if (state==0&&val==170)
          state=1;
          data(1)=val;
      elseif (state==1&&val==175)
          state=3;
          data(2)=val;
      elseif (state==3&&val<500)
          state=4;
          datlen=val;
          data(3)=val;
          datacnt=0;
      elseif (state==4&&datlen>0)
          datlen=datlen-1;
          data(4+datacnt)=val;
          datacnt=datacnt+1;
          if datlen==0
              state=5;
          end
      elseif (state==5)
          state=0;
              databuf=[databuf,data(4)*256+data(5)];
              time(i) = 0.05*i;
              databuf1=[databuf1,(data(6)*256+data(7))/1000];
              databuf2=[databuf2,data(8)*256+data(9)];
              i=i+1;
              dat=data(4)*256+data(5);
      %else
          %state=0;
      end
    end
    %save data.txt databuf -append -ascii;
    setappdata(handles.figure1,'datbuf',databuf);
    setappdata(handles.figure1,'datbuf1',databuf1);
    setappdata(handles.figure1,'datbuf2',databuf2);
    setappdata(handles.figure1,'time',time);
    %% ��û��ֹͣ��ʾ�������յ������ݽ��������׼����ʾ
        %% ���ݽ�����ʾ��״̬����������ΪҪ��ʾ���ַ�
            strHex = dec2hex(a')';
            strHex2 = [strHex; blanks(size(a, 1))];
            c = strHex2(:)';
        %% ����Ҫ��ʾ���ַ���
        strRec = [strRec c];
    %% ���²���
    setappdata(handles.figure1, 'strRec', strRec); %����Ҫ��ʾ���ַ���
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
%   �رմ���ʱ����鶨ʱ���ʹ����Ƿ��ѹر�
%   ��û�йرգ����ȹر�
%% ���Ҷ�ʱ��
t = timerfind;
%% �����ڶ�ʱ������ֹͣ���ر�
if ~isempty(t)
    stop(t);  %����ʱ��û��ֹͣ����ֹͣ��ʱ��
    delete(t);
end
%% ���Ҵ��ڶ���
scoms = instrfind;
%% ����ֹͣ���ر�ɾ�����ڶ���
try
    stopasync(scoms);
    fclose(scoms);
    delete(scoms);
end
%% �رմ���
delete(hObject);



% --- Executes on button press in ADplot.
function ADplot_Callback(hObject, eventdata, handles)

function save_data_Callback(hObject, eventdata, handles)

fid=fopen('data.txt','w+');
fid=fopen('thr.txt','w+');
fid=fopen('wz_acc.txt','w+');
fid=fopen('height.txt','w+');
close(figure(1))
m=msgbox('  �����������','');
pause(1);delete(m);
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function thr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate thr


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
strRec = getappdata(handles.figure1, 'strRec');
strRec='';
setappdata(handles.figure1, 'strRec',strRec);
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function thr1_Callback(hObject, eventdata, handles)
% hObject    handle to thr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thr1 as text
%        str2double(get(hObject,'String')) returns contents of thr1 as a double


% --- Executes during object creation, after setting all properties.
function thr1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function speed1_Callback(hObject, eventdata, handles)
% hObject    handle to speed1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of speed1 as text
%        str2double(get(hObject,'String')) returns contents of speed1 as a double


% --- Executes during object creation, after setting all properties.
function speed1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to speed1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function height1_Callback(hObject, eventdata, handles)
% hObject    handle to height1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of height1 as text
%        str2double(get(hObject,'String')) returns contents of height1 as a double


% --- Executes during object creation, after setting all properties.
function height1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
